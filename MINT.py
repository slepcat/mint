# failed implementation
# can not set up link

class mintObject:

	def __init__(self, solver):
		self.arg = solver.arg
		self.ret = solver.ret
		self.solver = solver

	def addArg(self, key, obj):
		if key in self.arg:
			self.arg[key] = obj
		else:
			self.riseErr("Invalid Argument Key")

	def removeArg(self, key):
		if key in self.arg:
			self.arg[key] = self.solver.arg[key] # Initial value
		else:
			self.riseErr("Invalid argument key")

	def addRet(self, key, obj):
		if key in self.ret:
			self.ret[key] = obj
		else:
			self.riseErr("Invalid return key")

	def removeRet(self, key):
		if key in self.ret:
			self.ret[key] = self.solver.ret[key]
		else:
			self.riseErr("Invalid return key")

	def getRet(self, key):
		if key in self.ret:
			if self.solver:
				return self.solver.solver(key, self)
			else:
				self.riseErr("No solver")
		else:
			self.riseErr("Invalid return key")


	def riseErr(self, errType):
		print(errType)

	def riseWarn(self, warnType):
		print(warnType)

class plus:
	def __init__(self):
		self.arg = {'x': 0, 'y': 0}
		self.ret = {'result': 0}

	def solver(self, key, obj):
		if key == 'result':
			return obj.arg['x'] + obj.arg['y']
		else:
			obj.riseErr("Invalid return key")

class minus:
	def __init__(self):
		self.arg = {'x': 0, 'y': 0}
		self.ret = {'result': 0}

	def solver(self, key, obj):
		if key == 'result':
			return obj.arg['x'] - obj.arg['y']
		else:
			obj.riseErr("Invalid return key")

