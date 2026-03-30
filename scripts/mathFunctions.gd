extends Node


func easeInSine(x):
	return 1 - cos((x * PI) / 2)
func easeOutSine(x):
	return sin((x * PI) / 2)
func easeInOutSine(x):
	return -(cos(PI * x) - 1) / 2
func easeInCubic(x):
	return pow(x,3)
func easeOutCubic(x):
	return 1 - pow(1 - x, 3)
func easeInOutCubic(x):
	if x < 0.5:
		return 4 * x * x * x
	else:
		return 1 - pow(-2 * x + 2, 3) / 2
func easeInQuint(x):
	return pow(x, 5)
func easeOutQuint(x):
	return 1 - pow(1 - x, 5)
func easeInOutQuint(x):
	if x < 0.5:
		return 16 * pow(x, 5)
	else:
		return 1 - pow(-2 * x + 2, 5) / 2
func easeInCirc(x):
	return 1 - sqrt(1 - pow(x, 2))	
func easeOutCirc(x):
	return sqrt(1 - pow(x - 1, 2))
func easeInOutCirc(x):
	if x < 0.5:
		return (1 - sqrt(1 - pow(2 * x, 2))) / 2
	else:
		return (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
func easeInElastic(x):
	const c4 := (2 * PI) / 3
	
	if x == 0:
		return 0
	elif x == 1:
		return 1
	else:
		return -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4)
func easeOutElastic(x):
	const c4 := (2 * PI) / 3
	
	if x == 0:
		return 0
	elif x == 1:
		return 1
	else:
		return pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1
func easeInOutElastic(x):
	const c5 := (2 * PI) / 4.5
	
	if x == 0:
		return 0
	elif x == 1:
		return 1
	elif x < 0.5:
		return -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
	else:
		return (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1
func easeInQuad(x):
	return x * x
func easeOutQuad(x):
	return 1 - pow(1 - x, 2)
func easeInOutQuad(x):
	if x < 0.5:
		return 2 * x * x
	else:
		return 1 - 2 * (1 - x) * (1 - x)
func easeInBack(x):
	const c1 := 1.70158
	const c3 := c1 + 1
	
	return c3 * x * x * x - c1 * x * x
func easeOutBack(x):
	const c1 := 1.70158
	const c3 := c1 + 1
	
	return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)
func easeInOutBack(x):
	const c1 := 1.70158
	const c2 := c1 * 1.525
	
	if x < 0.5:
		return (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
	else:
		return (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
func easeInBounce(x):
	return 1 - easeOutBounce(1 - x)
func easeOutBounce(x):
	const n1 := 7.5625
	const d1 := 2.75
	
	if x < 1 / d1:
		return n1 * x * x
	elif x < 2 / d1:
		return n1 * (x - 1.5 / d1) * (x - 1.5 / d1) + 0.75
	elif x < 2.5 / d1:
		return n1 * (x - 2.25 / d1) * (x - 2.25 / d1) + 0.9375
	else:
		return n1 * (x - 2.625 / d1) * (x - 2.625 / d1) + 0.984375
func easeInOutBounce(x):
	if x < 0.5:
		return (1 - easeOutBounce(1 - 2 * x)) / 2
	else:
		return (1 + easeOutBounce(2 * x - 1)) / 2
func linear(x):
	return x
