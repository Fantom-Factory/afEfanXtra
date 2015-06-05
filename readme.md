#efanXtra v1.1.20
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.1.20](http://img.shields.io/badge/pod-v1.1.20-yellow.svg)](http://www.fantomfactory.org/pods/afEfanXtra)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

`efanXtra` creates managed libraries of reusable [Embedded Fantom (efan)](http://pods.fantomfactory.org/pods/afEfan) components. Influenced by Java's [Tapestry 5](http://tapestry.apache.org/index.html), it pairs up Fantom classes and efan template files to encapsulate model / view behaviour.

`efanXtra` extends [efan](http://pods.fantomfactory.org/pods/afEfan), is powered by [IoC](http://pods.fantomfactory.org/pods/afIoc) and works great with [Slim](http://pods.fantomfactory.org/pods/afSlim) templates.

`efanXtra` excels in a [BedSheet](http://pods.fantomfactory.org/pods/afBedSheet) web environment, where URLs are automatically mapped to efan components (see [Pillow](http://pods.fantomfactory.org/pods/afPillow)), but is presented here context free for maximum reuse. Think email, code generation, blog posts, etc...

## Install

Install `efanXtra` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afEfanXtra

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afEfanXtra 1.1"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afEfanXtra/).

## Quick Start

1. Create a text file called `Overdue.efan`

        Dear <%= userName %>,
        
        It appears the following rented DVDs are overdue:
        
            <%= dvds.join(", ") %>
        
        Please return them at your convenience.
        
        <% app.renderSignOff("The Management") %>


2. Create a text file called `Overdue.fan`

        using afIoc
        using afEfanXtra
        
        const mixin Overdue : EfanComponent {
        
            // use afIoc services!
            @Inject
            abstract DvdService? dvdService
        
            // mixin fields can be accessed by the template
            abstract Str? userName
        
            // use lifecycle methods to initialise your components
            @InitRender
            Void initRender(Str userName) {
                this.userName = userName
            }
        
            // mixin methods can be called from the template
            Str[] dvds() {
                dvdService.findByName(userName)
            }
        }


3. Create a text file called `AppModule.fan`

        using afIoc
        
        class AppModule {
        
            static Void bind(ServiceBinder binder) {
                binder.bindImpl(DvdService#)
            }
        
            @Contribute { serviceType=EfanLibraries# }
            static Void contributeEfanLibs(Configuration config) {
        
                // contribute all components in the pod as a library named 'app'
                config["app"] = AppModule#.pod
            }
        }


4. Then to render an efan component:

        efanXtra.component(Overdue#).render(["Mr Smith"])



Full example source code available on [BitBucket](https://bitbucket.org/AlienFactory/afefanxtra/src/default/test/example/).

## Components

An efan component consists of a Fantom mixin that extends `EfanComponent` and a corresponding efan template file.

efanXtra does away with [efan's](http://pods.fantomfactory.org/pods/afEfan) `ctx` variable and instead lets the template access fields and methods of the component class directly.

### Mixins

Component mixins must be `const` and extend the [EfanComponent](http://pods.fantomfactory.org/pods/afEfanXtra/api/EfanComponent) mixin.

All fields and methods of the mixin are visible and directly accessible in the efan template. Components are created by [IoC](http://pods.fantomfactory.org/pods/afIoc) so feel free to annotate fields with `@Inject` just as you would with a service class.

See [Lifecycle Methods](#lifecycle) to see how to initialise and pass data into your components.

### Templates

By default, efan template files have the same name as the mixin, but with an `.efan` extension. If you wish the template to have a different name to the Fantom class, you can set an explicit URL with the [@TemplateLocation](http://pods.fantomfactory.org/pods/afEfanXtra/api/TemplateLocation) facet. Example:

```
@TemplateLocation { url=`fan://acmePod/templates/Notice.efan` }
const mixin Overdue : EfanComponent {
    ...
}
```

#### Pod Templates

A template may be a pod resource. For example, if you were to create a component called `Layout`, you may have the following files:

    /fan/components/Layout.fan  --> the mixin class
    /res/components/Layout.efan --> the template file

For efanXtra to find the template file, be sure to add `/res/components/` as a `resDir` in your `build.fan`.

    resDirs = [`res/components/`]

> **ALIEN-AID:** Note resource directories in `build.fan` are NOT nested. Adding `res/` will **NOT** add `res/components/`.

#### File System Templates

Templates may also be kept on the file system. This can be very handy for development, as templates on the file system don't require the pod to be re-built (or the application re-started) when they change.

To do this, contribute to [TemplateDirectories](http://pods.fantomfactory.org/pods/afEfanXtra/api/TemplateDirectories) to tell efanXtra where to look for templates:

```
class AppModule {

    @Contribute { serviceType=TemplateDirectories# }
    static Void contributeTemplateDirs(Configuration config) {
        config.add(`etc/components/`)
    }
}
```

Note that like Fantom resource directories, template directories are NOT nested; adding `etc/` will **NOT** add `etc/components/`.

Also note that the directory URIs must end in a slash.

## Libraries

Components are organised by libraries. A library encompasses all components within a pod. To use your efan components effectively, you should add your application pod as a library. Do this in your `AppModule`:

```
using afIoc
using afEfanXtra

class AppModule {

    @Contribute { serviceType=EfanLibraries# }
    static Void contributeEfanLibs(Configuration config) {

        // contribute all components in this pod as a library called 'app'
        config["app"] = AppModule#.pod
    }
}
```

Library classes are automatically injected as fields into your components. Library classes contain component render methods. In the [Quick Start Example](#quickStart), the library (in a field named `app`) would bave 2 render methods, available for use in your templates:

    app.renderOverdue(Str userName)
    app.renderSignOff(Str who)

This allows you to render components from within templates by calling `<libName>.render<ComponentName>(...)`. Example:

    <% app.renderSignOff("The Management") %>

> **ALIEN-AID:** Library render methods are logged at registry startup so you don't have to remember the method signatures!

## Lifecycle Methods

Components can be thought of as having a lifecycle for the duration of their render. Components can be made aware of the lifecycle by annotating callback methods with lifecycle facets. The lifecycle, and all state held in the component, only exists for the duration of the render.

![efanXtra Component Lifecycle](http://pods.fantomfactory.org/pods/afEfanXtra/doc/lifecycle.png)

### @InitRender

A method annotated with [@InitRender](http://pods.fantomfactory.org/pods/afEfanXtra/api/InitRender) will be called before any other. It allows you to initialise and prepare your component for rendering.

The `@InitRender` method may take any arguments, the signature will be mimicked by the containing library's render method. Example, if your `@InitRender` looks like:

```
const mixin MyComponent : EfanComponent {

    @InitRender
    Bool? initRender(Int x, Str y) { ... }
}
```

then the library render method will look like:

```
Obj? renderMyComponent(Int x, Str y, |->| bodyFunc := null) { ... }
```

This lets you pass any arguments you want into your components.

`@InitRender` methods may return `Bool`. If `true`, the template is rendered as usual. If `false`, then template rendering is skipped.

### @BeforeRender

A method annotated with [@BeforeRender](http://pods.fantomfactory.org/pods/afEfanXtra/api/BeforeRender) is invoked after `@InitRender` but before any template rendering. It may optionally take a `StrBuf` as a parameter, this will hold the contents of the current render buffer.

`@BeforeRender` methods may return `Bool`. If `true`, the template is rendered as usual. If `false`, then template rendering is skipped.

### @AfterRender

A method annotated with [@AfterRender](http://pods.fantomfactory.org/pods/afEfanXtra/api/AfterRender) is invoked after the template has rendered. It may optionally take a `StrBuf` as a parameter, this will hold the contents of the current render buffer.

`@AfterRender` methods may return `Bool`. If `true`, the template rendering ends. If `false`, template rendering is sent back to `@BeforeRender`. In this way, simple loops may be set up.

## Render Variables

Efan components can store state! Components may be `const` and they may be `mixins`, but they can still store variables that can be accessed and used by the rendering template. Taking the [Overdue](#quickStart) component as an example:

```
using afEfanXtra

const mixin Overdue : EfanComponent {

    abstract Str? userName

    @InitRender
    Void initRender(Str userName) {
        this.userName = userName
    }
}
```

`userName` is a render variable used by the efan template. Before `initRender()` is called, all render variables are reset to `null` (hence they need to be `nullable`). They may then be initialised during `initRender()`, and used and / or reset at any other point in the rendering lifecycle.

Note that state is *not* preserved between different renderings of the component.

## Use with Slim

`efanXtra` works great with [Slim](http://pods.fantomfactory.org/pods/afSlim)! Just add the following to your `AppModule` and `efanXtra` will automatically pick up component templates with the extension `.slim`:

```
using afIoc
using afSlim
using afEfanXtra

class AppModule {

    static Void bind(ServiceBinder binder) {
        binder.bindImpl(Slim#)
    }

    @Contribute { serviceType=TemplateConverters# }
    internal static Void contributeSlimTemplates(Configuration config, Slim slim) {
        config["slim"] = |File file -> Str| { slim.parseFromFile(file) }
    }
}
```

