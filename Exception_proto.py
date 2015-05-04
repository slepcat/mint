class MyException(object):
	"""docstring for MyException"""
	def __init__(self, arg):
		super(MyException, self).__init__()
		self.arg = arg
		

def throw():
	