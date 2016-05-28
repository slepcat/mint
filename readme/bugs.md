#bugfix:

##interpreter? Bug-001 [Not Yet]
* memory leak suspected. After every eval, App's memory consumption increase several hundred KB.
* After each loding of file, memory consumption increase. May be there is some problem around loading/closing file & memory management?

##opengl Bug-002 [Not Yet]
* openglview isn't drawn in intel gpu model.

##Display Instance Bug-003 [Partialy Fixed]
* deinit of Display class isn't called when Display leaf removed or reimported. Polygon which drawn by the removed display leaf is not removed as expected.
* Cause -> MintController instance have a record of MintCommand excuted for redo/undo operation (not implemented yet). And it hold removed display instance & prevent release. Also, see Bug-004.
* Solution -> Under consideration. Tempolary MintController's record is suspended. Also, see Bug-004.

##Display Instance Cycle Ref Bug-004 [Fixed]
* Display instance was not released as expected.
* Cause of bug -> Memory leak is caused by cycle reference of Env instances. When pre-processor imported lib file, pre-processor copy procedure instance with symbol key in imported lib's env to interpreter's global env instance. And imported lib's env was expected to be released. But procedure hold initial (when proc declared) env instance and it was not released as expected.
* Solution -> Pre-processor simply use interpreter's global env instance instead of copy of it. When pre-processor is called again, an old symbol is overwritten and an old variable is released.

##StdErrOut not work Bug-005
* Result text is not printed to leaf.
* Cause -> 'Selector' expression is fixed to Swift 2.x standard. Also, Macro Pre-Processor replace 'Pair' instance with new uid. StdErrPort failed to send err msg to correct leaf.
* Fix - > 'Selector' expression fixed. (#selector()) Macro Pre-Processor replace 'Pair' with same uid.

##Import self cause infinite loop Bug-006 [Fixed]
* Import self cause infinite loop and crash.
* Cause -> Pre-processor cannot check self import err.
* Solution -> Interpreter have a record of imported file as filepath. This prevent import same file twice. (self import allowed once)