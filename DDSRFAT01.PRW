//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA        Chr(13)+Chr(10)

// Relat�rio de Separacao de Pedidos de Vendas

User Function DDSRFAT01()
Local aArea     := GetArea()
Local oReport
Local lEmail    := .F.
Local cPara     := ""
Private cPerg   := "DDSRFAT01"
Private cGrupos := ""

CriaSx1(cPerg)
if ! Pergunte(cPerg,.T.)
	restArea( aArea )
	return nil
endif

fSelGrupos()	// sele��o dos grupos de produtos

//Cria as defini��es do relat�rio
oReport := fReportDef()

//Ser� enviado por e-Mail?
If lEmail
	oReport:nRemoteType := NO_REMOTE
	oReport:cEmail := cPara
	oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
	oReport:SetPreview(.F.)
	oReport:Print(.F., "", .T.)
	//Sen�o, mostra a tela
Else
	oReport:PrintDialog()
EndIf

RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
| Func:  fReportDef                                                             |
| Desc:  Fun��o que monta a defini��o do relat�rio                              |
*-------------------------------------------------------------------------------*/

Static Function fReportDef()
Local oReport
Local oSectDad := Nil

//Cria��o do componente de impress�o
oReport := TReport():New(    "DDSRFAT01",;        //Nome do Relat�rio
"Relatorio de Separacao de Pedidos",;        //T�tulo
cPerg,;        //Pergunte ... Se eu defino a pergunta aqui, ser� impresso uma p�gina com os par�metros, conforme privil�gio 101
{|oReport| fRepPrint(oReport)},;        //Bloco de c�digo que ser� executado na confirma��o da impress�o
"Exibe o relatorio de separacao de pedidos")        //Descri��o
oReport:SetTotalInLine(.F.)
oReport:lParamPage := .F.
oReport:oPage:SetPaperSize(9) //Folha A4
oReport:SetPortrait()
oReport:nFontBody := 7


//Criando a se��o de dados
oSectDad := TRSection():New(    oReport,;        //Objeto TReport que a se��o pertence
"Dados",;        //Descri��o da se��o
{"QRY_AUX"})        //Tabelas utilizadas, a primeira ser� considerada como principal da se��o
oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha

//Colunas do relat�rio
TRCell():New(oSectDad, "CLIENTE", "QRY_AUX", "Cliente", /*Picture*/, 29, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "PEDIDO", "QRY_AUX", "Pedido", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "GRUPO", "QRY_AUX", "Grupo", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "DESCRICAO", "QRY_AUX", "Descricao", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "QUANTIDADE", "QRY_AUX", "Quantidade", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "C6_UM", "QRY_AUX", "Unidade", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport

/*-------------------------------------------------------------------------------*
| Func:  fRepPrint                                                              |
| Desc:  Fun��o que imprime o relat�rio                                         |
*-------------------------------------------------------------------------------*/

Static Function fRepPrint(oReport)
Local aArea    := GetArea()
Local cQryAux  := ""
Local oSectDad := Nil
Local nAtual   := 0
Local nTotal   := 0

//Pegando as se��es do relat�rio
oSectDad := oReport:Section(1)

//Montando consulta de dados
cQryAux := ""
cQryAux += "SELECT A1_NREDUZ CLIENTE,C5_NUM PEDIDO, SUBSTRING(C5_EMISSAO,7,2)+'/'+SUBSTRING(C5_EMISSAO,5,2)+'/'+SUBSTRING(C5_EMISSAO,1,4) EMISSAO,ACY_DESCRI GRUPO,C6_PRODUTO PRODUTO,C6_DESCRI DESCRICAO, C6_QTDVEN QUANTIDADE, C6_UM FROM "        + STR_PULA
cQryAux += RetSQLName("SC6") +" A, "+RetSQLName("SC5") +" B, "+RetSQLName("SA1") +" E "
cQryAux += " left join "+retSqlName("ACY")+" ACY on ACY_FILIAL='"+xFilial("ACY")+"' and ACY_GRPVEN=A1_GRPVEN and ACY.D_E_L_E_T_='' , "
cQryAux += RetSQLName("SB1") +" C "+"join "+retSqlName("SBM")+" SBM on BM_FILIAL='"+xFilial("SBM")+"' and BM_GRUPO=B1_GRUPO and SBM.D_E_L_E_T_=' '"
cQryAux += "WHERE A.D_E_L_E_T_ = ''AND B.D_E_L_E_T_ = '' AND C.D_E_L_E_T_ = ''  AND E.D_E_L_E_T_ = ''  "        + STR_PULA
cQryAux += "AND SUBSTRING(C5_FILIAL,1,2) = '"+SubStr(cFilAnt,1,2)+"' "       + STR_PULA
cQryAux += "AND SUBSTRING(A1_FILIAL,1,2) = '"+SubStr(cFilAnt,1,2)+"' "       + STR_PULA
cQryAux += "AND C5_NUM = C6_NUM"        + STR_PULA
cQryAux += "AND C5_FILIAL = C6_FILIAL"        + STR_PULA
cQryAux += "AND C6_CLI+C6_LOJA = A1_COD+A1_LOJA"        + STR_PULA
cQryAux += "AND C6_PRODUTO = B1_COD"        + STR_PULA
--cQryAux += "AND A1_FILIAL = ACY_FILIAL"        + STR_PULA
--cQryAux += "AND A1_GRPVEN = ACY_GRPVEN "        + STR_PULA
cQryAux += "AND BM_GRUPO = B1_GRUPO "       + STR_PULA
cQryAux += "AND BM_FILIAL = B1_FILIAL"       + STR_PULA
cQryAux += "AND C5_EMISSAO between '"+DtoS(mv_par01)+"' and '"+DtoS(mv_par02)+"' "       + STR_PULA
//cQryAux += "AND C5_NUM between '"+mv_par03+"' and '"+mv_par04+"' "       + STR_PULA

//If ! Empty(mv_par03)
//	cQryAux += "AND B1_GRUPO  = '"+mv_par03+"' "       + STR_PULA
//EndIf

if ! empty( cGrupos )
	cQryAux += "and B1_GRUPO in ("+cGrupos+")"
endif

If ! Empty(mv_par04)
	cQryAux += "AND A1_GRPVEN = '"+mv_par04+"' "       + STR_PULA
EndIf
cQryAux += "ORDER BY C5_NUM+C6_DESCRI "       + STR_PULA

cQryAux := ChangeQuery(cQryAux)

//Executando consulta e setando o total da r�gua
TCQuery cQryAux New Alias "QRY_AUX"
Count to nTotal
oReport:SetMeter(nTotal)

//Enquanto houver dados
oSectDad:Init()
QRY_AUX->(DbGoTop())

cNumPed 	:= QRY_AUX->PEDIDO
nTotItem	:= 0
While ! QRY_AUX->(Eof())

    If cNumPed <> QRY_AUX->PEDIDO

		//nTotItem := 0
        oReport:endPage()
        oReport:startPage()
    EndIf
	//nTotItem += QRY_AUX->QUANTIDADE
    cNumPed := QRY_AUX->PEDIDO
            
	//Incrementando a r�gua
	nAtual++
	oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
	oReport:IncMeter()
	
	//Imprimindo a linha atual
	oSectDad:PrintLine()
	
	QRY_AUX->(DbSkip())
EndDo
oSectDad:Finish()
QRY_AUX->(DbCloseArea())

RestArea(aArea)
Return
Static Function CriaSx1(cPerg)
xPutSx1(cPerg,"01","Emissao de?"	 ,"","" ,"mv_ch1","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",,,)
xPutSx1(cPerg,"02","Emissao Ate?"	 ,"","" ,"mv_ch2","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",,,)
xPutSx1(cPerg,"03","GRP Produto?","",""     ,"mv_ch3","C",06,0,0,"G","","SBM","","","mv_par03","","","","","","","","","","","","","","","","","","","")
xPutSx1(cPerg,"04","GRP Cliente?","",""     ,"mv_ch4","C",06,0,0,"G","","ACY","","","mv_par04","","","","","","","","","","","","","","","","","","","")
//xPutSx1(cPerg,"03","Pedido de?" ,"",""      ,"mv_ch3","C",06,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","","","","")
//xPutSx1(cPerg,"04","Pedido ate?","",""      ,"mv_ch4","C",06,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","","","","")

//U_XPutSx1(cPerg,"01","?"  ,"Do C�digo Interno?" ,"Do C�digo Interno?" ,"mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01")
//U_XPutSx1(cPerg,"01","SUPERVISOR?"  ,"Do C�digo Interno?" ,"Do C�digo Interno?" ,"mv_ch1","C",06,0,0,"G","","SA3","","","mv_par01")
Return

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
cF3, cGrpSxg,cPyme,;
cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
cDef02,cDefSpa2,cDefEng2,;
cDef03,cDefSpa3,cDefEng3,;
cDef04,cDefSpa4,cDefEng4,;
cDef05,cDefSpa5,cDefEng5,;
aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey
Local lPort := .f.
Local lSpa := .f.
Local lIngl := .f.

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

cPyme    := Iif( cPyme           == Nil, " ", cPyme          )
cF3      := Iif( cF3           == NIl, " ", cF3          )
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     )
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      )
cHelp      := Iif( cHelp          == Nil, "" , cHelp          )

dbSelectArea( "SX1" )
dbSetOrder( 1 )

// Ajusta o tamanho do grupo. Ajuste emergencial para valida��o dos fontes.
// RFC - 15/03/2007
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

If !( DbSeek( cGrupo + cOrdem ))
	
	cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
	cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
	cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
	
	Reclock( "SX1" , .T. )
	
	Replace X1_GRUPO   With cGrupo
	Replace X1_ORDEM   With cOrdem
	Replace X1_PERGUNT With cPergunt
	Replace X1_PERSPA With cPerSpa
	Replace X1_PERENG With cPerEng
	Replace X1_VARIAVL With cVar
	Replace X1_TIPO    With cTipo
	Replace X1_TAMANHO With nTamanho
	Replace X1_DECIMAL With nDecimal
	Replace X1_PRESEL With nPresel
	Replace X1_GSC     With cGSC
	Replace X1_VALID   With cValid
	
	Replace X1_VAR01   With cVar01
	
	Replace X1_F3      With cF3
	Replace X1_GRPSXG With cGrpSxg
	
	If Fieldpos("X1_PYME") > 0
		If cPyme != Nil
			Replace X1_PYME With cPyme
		Endif
	Endif
	
	Replace X1_CNT01   With cCnt01
	If cGSC == "C"               // Mult Escolha
		Replace X1_DEF01   With cDef01
		Replace X1_DEFSPA1 With cDefSpa1
		Replace X1_DEFENG1 With cDefEng1
		
		Replace X1_DEF02   With cDef02
		Replace X1_DEFSPA2 With cDefSpa2
		Replace X1_DEFENG2 With cDefEng2
		
		Replace X1_DEF03   With cDef03
		Replace X1_DEFSPA3 With cDefSpa3
		Replace X1_DEFENG3 With cDefEng3
		
		Replace X1_DEF04   With cDef04
		Replace X1_DEFSPA4 With cDefSpa4
		Replace X1_DEFENG4 With cDefEng4
		
		Replace X1_DEF05   With cDef05
		Replace X1_DEFSPA5 With cDefSpa5
		Replace X1_DEFENG5 With cDefEng5
	Endif
	
	Replace X1_HELP With cHelp
	
	PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	
	MsUnlock()
Else
	
	lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
	lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA)
	lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG)
	
	If lPort .Or. lSpa .Or. lIngl
		RecLock("SX1",.F.)
		If lPort
			SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
		EndIf
		If lSpa
			SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
		EndIf
		If lIngl
			SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
		EndIf
		SX1->(MsUnLock())
	EndIf
Endif

RestArea( aArea )

Return nil


//--------------------------------------------------------
static function fSelGrupos()
local aGrupos := {}
local aArea   := getArea()
local oDlg
local oLst
local nAt
local nI
local oOk  	:= LoadBitmap(GetResources(), 'LBOK')
local oNo  	:= LoadBitmap(GetResources(), 'LBNO')

	cGrupos := ""

	SBM->( dbSetOrder(1))
	SBM->( dbSeek( xFilial("SBM"), .T. ) )
	while ! SBM->( eof() ) .and. SBM->BM_FILIAL == xFilial("SBM")
		aadd( aGrupos, { alltrim(MV_PAR03)==alltrim(SBM->BM_GRUPO), SBM->BM_GRUPO, SBM->BM_DESC })
		SBM->( dbSkip() )
	end

	define msDialog oDlg title "Selecao de Grupos de Produto" from 0,0 to 300,450 pixel
	@ 1,1 listbox oLst var nAT fields header "", "Codigo", "Descricao" size 224, 128 pixel of oDlg

	oLst:SetArray(aGrupos)
	
	oLst:bLine :=	{|| {;
							iif(aGrupos[oLst:nAt,01], oOk, oNo ),;
							aGrupos[oLst:nAt,02],;
							aGrupos[oLst:nAt,03],;
	}}

	oLst:bLDbLClick	:= { || (aGrupos[oLst:nAt][1] := ! aGrupos[oLst:nAt][1], oLst:Refresh()) }

	@ 135,184 button "Ok" size 40,12 of oDlg pixel action oDlg:end()
	activate msDialog oDlg

	for nI := 1 to len(aGrupos)
		if aGrupos[nI,1]
			cGrupos += iif(empty(cGrupos), "", ",") + "'" + aGrupos[nI,2] + "'"
		endif
	next

	restArea( aArea )
return nil