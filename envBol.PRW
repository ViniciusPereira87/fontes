#include "totvs.ch"
/*/{Protheus.doc} envBol
Rotina - gera��o de boletos .PDF e envio por e-mail a clientes
@type function
@author Cristiam Rossi
@since 02/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function envBol( _cPrefixo, _cDupl )
local   aArea      := getArea()
local   cPrefixo   := padR( _cPrefixo, len(SE1->E1_PREFIXO))
local   cNumero    := padR( _cDupl   , len(SE1->E1_NUM)    )
local   cFilK	   := xFilial("SE1")
local   cPasta
private cFilePrint := ""

	cPasta   := superGetMV("FS_FOLBOL",,"c:\boleto")
	MakeDir( cPasta )
	cPasta   += "\"

	if empty( cNumero )
		return nil
	endif

	SE1->( dbSetOrder(1) )
	if ! SE1->( dbSeek( xFilial("SE1")+ cPrefixo + cNumero, .T. ) )
		restArea( aArea )
		return nil
	endif
	
	If SE1->E1_TIPO <> "NF "
		SE1->(DbSkip())
		If xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM <> cFilK+cPrefixo+cNumero
			RestArea( aArea )
			Return nil
		EndIf 
	EndIf 		

	if empty( SE1->E1_PORTADO )
		AutoGrLog("Boleto n�o poder� ser enviado por e-mail, T�tulo ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"] sem Portador")
		//msgAlert("Boleto n�o poder� ser enviado por e-mail, T�tulo ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"] sem Portador")
		return nil
	endif
	
	SA6->( dbSetOrder(1) )
	if ! SA6->( dbSeek( xFilial("SA6") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA ) )
		msgAlert("Boleto n�o poder� ser enviado por e-mail, Banco/Ag�ncia/Conta n�o encontrada. T�tulo: ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"]")
		return nil
	endif

	if empty( SA6->A6_NUMBCO )
		msgAlert("Boleto n�o poder� ser enviado por e-mail, n�mero do banco n�o informado no cadastro do Banco. T�tulo: ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"] Banco: ["+SE1-E1_PORTADO+"]")
		return nil
	endif

	SA1->( dbSetOrder(1) )
	if ! SA1->( dbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA) )
		msgAlert("Boleto n�o poder� ser enviado por e-mail, cliente n�o encontrado. T�tulo: ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"]")
		return nil
	endif

	if empty( SA1->A1_EMAIL )
		//msgAlert("Boleto n�o poder� ser enviado por e-mail, E-mail do cliente em branco. T�tulo: ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"]")
		AutoGrLog("Boleto n�o poder� ser enviado por e-mail, E-mail do cliente em branco. T�tulo: ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"]")
		return nil
	endif

	if alltrim(SA6->A6_NUMBCO) == "341"		// ITA�
		u_impBOLIT( cPrefixo, cNumero, .T. )
	elseif alltrim(SA6->A6_NUMBCO) == "748"		// SICREDI
		u_impBOL( cPrefixo, cNumero, .T. )
	else
		msgAlert("Boleto n�o poder� ser enviado por e-mail, boletos configurados 341-Ita� e 748-Sicredi. T�tulo: ["+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"]")
		return nil
	endif

	if empty( cFilePrint )
		msgAlert("Boleto n�o poder� ser enviado por e-mail, ocorreu erro na gera��o do anexo .PDF")
		return nil
	endif

	if ! file( cPasta + cFilePrint + ".pdf" )
		msgAlert("Boleto n�o poder� ser enviado por e-mail, n�o encontrou anexo .PDF")
		return nil
	endif

/*
if ! msgYesNo("Ser� enviado boleto por e-mail p/ "+SA1->A1_EMAIL+CRLF+"Continua?", "Envio de Boleto")
	restArea( aArea )
	return nil
endif
*/

	if U_sndMail( SA1->A1_EMAIL, "boleto(s) ref NF: "+cNumero, "Prezado cliente,<br />segue anexo os boletos da NF: "+cNumero+"<br /><br />atenciosamente<br />"+SM0->M0_FILIAL,  {cPasta + cFilePrint + ".pdf"} /*aAnexo*/, /*cCopia*/, /*cOculta*/, .T. /*lQuiet*/)
		AutoGrLog("Boleto enviado com sucesso! T�tulo: "+cPrefixo+"-"+cNumero+ "E-mail:"+SA1->A1_EMAIL)		
	else
		msgAlert("Falha ao enviar Boleto por e-mail! T�tulo: "+cPrefixo+"-"+cNumero+"E-mail:"+SA1->A1_EMAIL)		
	endif

	restArea( aArea )
return nil
