#include "totvs.ch"
/*/{Protheus.doc} FA60TRAN
P.E. - Ponto de Entrada no final da rotina de transferencia de t�tulos a receber
@type function
@author Cristiam Rossi
@since 03/02/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function FA60TRAN
local aArea := getArea()

	if SE1->E1_SITUACA != "0"
		if msgYesNo( "Deseja voltar a situa��o do t�tulo p/ carteira?", "Mudan�a do t�tulo para Carteira" )
			recLock("SE1", .F.)
			SE1->E1_SITUACA := "0"
			msUnlock()
		endif
	endif

	restArea( aArea )
return nil
