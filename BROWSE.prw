#include 'totvs.ch'


//Rotina para retornar a descrição do cliente e fornecedor nas rotinas de PV e PC

USER FUNCTION BROWSE()

Local _cRetorno := ''
Local _cTipo 	:= ''

If FunName() $ 'MATA410'
	If	AllTrim(SC5->C5_TIPO)$'D/B'
    	_cRetorno := Posicione("SA2",1,Substr(SC5->C5_FILIAL,1,2)+Space(4)+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"SA2->A2_NREDUZ")     
	Else
	    _cRetorno := Posicione("SA1",1,Substr(SC5->C5_FILIAL,1,2)+Space(4)+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"SA1->A1_NREDUZ") 
	Endif
Endif

If FunName() $ 'MATA460A'
	_cTipo :=  Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"SC5->C5_TIPO")
	
	If  AllTrim(_cTipo)$'D/B'
    	_cRetorno := Posicione("SA2",1,Substr(SC9->C9_FILIAL,1,2)+Space(4)+SC9->C9_CLIENTE+SC9->C9_LOJA,"SA2->A2_NREDUZ")     
	Else
		_cRetorno := Posicione("SA1",1,Substr(SC9->C9_FILIAL,1,2)+Space(4)+SC9->C9_CLIENTE+SC9->C9_LOJA,"SA1->A1_NREDUZ") 
	Endif
Endif

If FunName() $ 'MATA103' .Or. (FunName() $ 'SPEDNFE' .And. Substr(MV_PAR01,1,1)$"2"/*Entrada*/)
	If AllTrim(SF1->F1_TIPO) $'D/B'
	    _cRetorno := Posicione("SA1",1,Substr(SF1->F1_FILIAL,1,2)+Space(4)+SF1->F1_FORNECE+SF1->F1_LOJA,"SA1->A1_NREDUZ")     
	Else
    	_cRetorno := Posicione("SA2",1,Substr(SF1->F1_FILIAL,1,2)+Space(4)+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_NREDUZ")
	Endif
Endif

If FunName() $ 'SPEDNFE' .And. Substr(MV_PAR01,1,1)$"1"/*Saida*/
	If AllTrim(SF2->F2_TIPO) $'D/B'
	    _cRetorno := Posicione("SA2",1,Substr(SF2->F2_FILIAL,1,2)+Space(4)+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_NREDUZ")     
	Else
    	_cRetorno := Posicione("SA1",1,Substr(SF2->F2_FILIAL,1,2)+Space(4)+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NREDUZ")
	Endif
Endif

Return _cRetorno