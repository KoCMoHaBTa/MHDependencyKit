#  MHDependencyKit

[![Build Status](https://app.bitrise.io/app/960ddc82f9c41a2d/status.svg?token=b-p9ilqSddTTaN13e4YYOw&branch=master)](https://app.bitrise.io/app/960ddc82f9c41a2d)

**MHDependencyKit** is lightweight library that helps resolves dependencies between objects in a workflow manner. 

Its goal is to solve the complexity of resolving dependencies and data transfer between UIViewController transitions.
In its core, the abstraction is not limited to UIKit, so its possible to define your own implementation of how to resolve dependenies by just implementing the `DependencyResolver` protocol.

### Highlights

- **DependencyCoordinator** - this is the core type responsible for registering and resolving dependencies
- **DependencyResolver** - a protocol that defines a type responsible for resolving dependencies between a provider and a consumer
- **ConsumerDependencyResolver** - a protocol that defines a type responsible for resolving dependencies to a consumer, without a provider
- **UIViewControllerDependencyResolver** - a resolver between 2 view controlers, that appear directly one after another
- **UIViewControllerConsumerDependencyResolver** - a resolver for a single view controller
- **UIViewControllerContextDependencyResolver** - a resolver between 2 view controllers, no matter at what point they appear in the app
- **UIStoryboardSegueDependencyResolver** - a resolver for a given storyboard instance

## How to (with examples)

All examples below will be with view controllers, however you are not limited to use view controlers.

The most value of this library comes from [Automatic dependency resolution with Storyboard Segues and context depdendencies](#Automatic_dependency_resolution_with_Storyboard_Segues_and_context_depdendencies)

### Registering dependencies

You can resolve dependencies between any 2 concrete types of view controller by specifying them as source and destination.

```
//1 
let coordinator = DependencyCoordinator.default

//2
let resolver = UIViewControllerDependencyResolver { (source: ContactListViewController, destination: ContactDetailsViewController) in

	//3
    destination.contactID = source.selectedContact.id
}

//4
coordinator.register(dependencyResolver: resolver)
```

1. There is default shared instance of **DependencyCoordinator**, that we are going to use, however you are not limited to it.
2. Create an instance of a dependncy resolver of your choice. Make sure to specify source and destination types - for example we show a contact details screen for a selected contact from a list.
3. Resolve the depndencies between the 2 concrete view controllers
4. Registers the dependency resolver with the coordinator

### Using configurable protocols

Specifying concrete types is easy and fast, however if you have a comples UI and workflow with a lot of types - you might end up with endless combinations of them.

A more generic approach is to use configurable protocols for common dependencies.

```
//1
protocol ContactIDConfigurable: class {
	var contactID: String? { get set }
}

//2
let coordinator = DependencyCoordinator.default

//3
let resolver = UIViewControllerContextDependencyResolver { (source: ContactIDConfigurable, destination: ContactIDConfigurable) in

	//4
    destination.contactID = source.contactID
}

//5
coordinator.register(dependencyResolver: resolver)
```

1. Pretty often we have to transfer a specific contact id, so we define a configurable protocol to represent that dependency
2. There is default shared instance of **DependencyCoordinator**, that we are going to use, however you are not limited to it.
3. Create an instance of a dependncy resolver of your choice. Make sure to specify source and destination types as the configurable protocol
4. Resolve the depndencies between the 2 objects
5. Registers the dependency resolver with the coordinator

Using this approach will allow to define single registration for common dependencies between screens. 

The value of this approach is hugely boosted when used with **UIViewControllerContextDependencyResolver**, since this resolver allows resolving dependencies between screens no matter of their position in the workflow.

### Automatic dependency resolution with Storyboard Segues and context depdendencies

A hook is attached to UIViewController.prepare(for:sender:) that resolves the dependenceis between the source and destination view controller. 

It is very convenient to use **UIViewControllerContextDependencyResolver** in this case, because it will resolve dependencies between controllers no matter of their position in the workflow.

The only consideration you need to take care of is, if you override  UIViewController.prepare(for:sender:) - you must call super.

### Storyboard Segues extensions

Another very powerful extension to storyboards is the ability to perform a segue with inline one time dependency resolution, as following:

```
//1
class MyViewController: UIViewController {

	@IBAction func buttonTapped() {
	
		//2
		self.performSegue(withIdentifier: "showNextScreen", sender: nil) { (source, destination: MyAwesomeViewController) in
            
            //3
            destination.title = "My Awesome Screen"
        }
	}
}
```

1. We are located in a custom view controller with and example action, triggered by a tap from the UI
2. We perform a custom segue by using one of the new extension methods that allow us to provide a closure that resolve the destination dependencies
3. We set the title of the destination

The great part here is that in most of the cases you will be aware of what the next screen is and you also have context of the current screen.

Keep in mind that this resolution is only temporary and is only valid withtin the scope of this call, eg. it will not be called from other workflow actions.


### Manual dependency resolution

In case you don't use storyboards or just have some special case where you create and manage you view controllers manually - you will also need to resolve the depdenncies manually.

```
//1
let coordinator: DependencyCoordinator = ...

//2
let contactList: UIViewController = ...
let contactDetails: UIViewController = ...

//3
coordinator.resolveDependencies(from: contactList, to: contactDetails)
```
1. Setup and register your dependencies
2. Setup your view controllers and prepare to resolve dependencies between 2 of them
3. Manually resolve dependencies from contactList to contactDetails using the coordinator.

------

Example coming soon.
