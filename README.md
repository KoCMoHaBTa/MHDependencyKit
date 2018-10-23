#  MHDependencyKit

**MHDependencyKit** is lightweight library that helps resolves dependencies between objects in a workflow manner. 

Its goal is to solve the complexity of resolving dependencies and data transfer between UIViewController transitions.
In its core, the abstraction is not limited to UIKit, so its possible to define your own implementation of how to resolve dependenies by just implementing the `DependencyResolver` protocol.


------

- take segue coordinator from MHAppKit
- remove all segue specific code and replace it with generics
- add specific implementation for segues and uiviewcontrollers

this way - we can call it DependencyCoordinator
that can work with any desired setup and will have default implementation for segues and uiviewcontrollers

- ot be able to resolve dependencies to destination only


DepencyCoordinator
Resolve from provider to consumer 

UI tests for
- segue method swizzling

Alternative manual approaches 
- base class
- Custom system segue animation

In both loose resolving between relationship segues



----
destination should take the coorinator that configures it


this of a way to handle 
