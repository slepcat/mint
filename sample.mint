

// mockup code
// 1. C like

mesh housing(double size, double weight, int type) {
	return mesh
}

// swift like

// declare
class housing {
	init {
		size = 10.0
		weight = 30.0
		type = 1
	}

	solve {
		union1 = Union(mesh1: subtract1, mesh2: union2) {
			subtract1 = Subtract(target: rotate1, subtract: cube2) {
				rotate1 = Rotate(mesh: cube1, x: 30) {
					cube1 = Cube(height: size)
				}
				cube2 = Cube(center:Vector(x: 5))
			}

			union2 = Union(mesh1: cylinder1, mesh2: cube1) {
				cylinder1 = Cylinder()
			}
		}
	}


}

// Python like

class Housing:
	def __init__:
		size = 10.0
		weight = 30.0
		type = 1

	def __solve__:
		<- union1 = Union(subtract1, union2):
			<- subtract1 = Subtract(rotate1, cube2):
				<- rotate1 = Rotate(cube1, 30, 0, 0):
					<- cube1 = Cube():
				<- cube2 = Cube():

			<- union2 = Union(cylinder1, cube1):
				<- cylinder1 = Cylinder():

	def __accessor__:
		mesh <- Housing()



tab = Subtract()
	target: frame_tab = Union()
		mesh1: body = Cube()
			center: vec = Vector()
				x: 10
				y: 0
				z: 0

			widht: 10
			depth: 20
			height: constraint = Double()
				double: 8
					mesh1: body = Cube()
						center: vec = Vector()
							x: 10
							y: 0
							z: 0

						widht: 10
						depth: 20
						height: constraint = Double()
							double: 8

		mesh2: key = Cylinder()
			center: vec = Vector(x: 0, y: 0, z: 8)
			height: constraint
			radius: 3.2

	subtract: hole = Cylinder()
		center: vec
		height: constraint
		radius: 2


leaf Spam:
	def arguments:
		meattype = Int(10)
		thickness = Double(double: 8)
		weight = Double()
			double: 20

	def solve:
		spam = Cube()
			width: x = Python()
				import math

				size = weight / thickness
				x = math.root(size)
				return x

			depth: x
			height: thickness

		type = meattype

	def return:
		spam
		type

leaf BigSpam(Spam, USSpam):
	def arguments:

	def solve:
		override spam = Cube()
			width: x = Python()
				size = weight / thickness
				return size

			depth: x
			height: thickness

	def return:
		override spam

interface USSpam:
	def arguments:
		thickness = Int()

	def return:
		spam = Mesh()
		type = Int()




