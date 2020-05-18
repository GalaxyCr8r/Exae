extends ObjStation

var artificalUsage = 10

func tick():
	.tick()
	
	artificalUsage -= 1
	if artificalUsage == 0:
		artificalUsage = 7
		if cargoBay.wareNameAmount("Sheet Metal") > 0:
			cargoBay.removeWareName("Sheet Metal", 5, 1)
