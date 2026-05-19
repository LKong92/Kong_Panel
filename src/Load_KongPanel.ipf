#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma DefaultTab={3,20,4}

// Open this file to compile the complete Kong Panel package.
// It includes all panel action procedures before the panel is launched.

#include "Kong_Igor_panel"

Menu "Kong Panel"
	"Open Kong Panel", Kong_Igor_panel()
End
