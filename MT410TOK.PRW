#include "totvs.ch"
//-------------------------------------------------------
/*/{Protheus.doc} MT410TOK
Ponto de Entrada - Tudo OK - Pedido de Vendas

@type function
@author Cristiam Rossi
@since 08/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------
user function MT410TOK()
local aArea			:= getArea()
local lOk			:= .T.

	u_PVxPESO()		// atualiza Peso Bruto e L�quido

	restArea( aArea )
return lOk
