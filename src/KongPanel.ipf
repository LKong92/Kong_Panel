#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma DefaultTab={3,20,4}

// Kong Panel package entry point.
// Put this folder in Igor Pro's User Procedures folder, then include "KongPanel".

#include "Kong_Igor_panel"

Menu "Kong Panel"
	"Open Kong Panel", Kong_Igor_panel()
End
