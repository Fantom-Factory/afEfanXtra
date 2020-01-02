# efanXtra v2.0.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v2.0.0](http://img.shields.io/badge/pod-v2.0.0-yellow.svg)](http://eggbox.fantomfactory.org/pods/afEfanXtra)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

efanXtra creates managed libraries of reusable [Embedded Fantom (efan)](http://eggbox.fantomfactory.org/pods/afEfan) components. Influenced by Java's [Tapestry 5](http://tapestry.apache.org/index.html), it pairs up Fantom classes and efan template files to encapsulate model / view behaviour.

efanXtra extends [efan](http://eggbox.fantomfactory.org/pods/afEfan), is powered by [IoC](http://eggbox.fantomfactory.org/pods/afIoc) and works great with [Slim](http://eggbox.fantomfactory.org/pods/afSlim) templates.

efanXtra excels in a [BedSheet](http://eggbox.fantomfactory.org/pods/afBedSheet) web environment, where URLs are automatically mapped to efan components (see [Pillow](http://eggbox.fantomfactory.org/pods/afPillow)), but is presented here context free for maximum reuse. Think email, code generation, blog posts, etc...

## <a name="Install"></a>Install

Install `efanXtra` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afEfanXtra

Or install `efanXtra` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afEfanXtra

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afEfanXtra 2.0"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afEfanXtra/) - the Fantom Pod Repository.

## <a name="quickStart"></a>Quick Start

1. Create a text file called `Overdue.efan`    Dear <%= userName %>,
    
    It appears the following rented DVDs are overdue:
    
        <%= dvds.join(", ") %>
    
    Please return them at your convenience.
    
    <%= app.renderSignOff("The Management") %>


2. Create a text file called `Overdue.fan`    using afIoc
    using afEfanXtra
    
    class Overdue : EfanComponent {
    
        // use afIoc services!
        @Inject
        DvdService? dvdService
    
        // fields can be accessed by the template
        Str? userName
    
        // standard it-block ctor for ioc injection
        new make(|This| f) { f(this) }
    
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


3. Create a text file called `AppModule.fan`    using afIoc
    
    const class AppModule {
    
        Void defineServices(RegistryBuilder defs) {
            defs.addService(DvdService#)
        }
    
        @Contribute { serviceType=EfanLibraries# }
        Void contributeEfanLibs(Configuration config) {
    
            // contribute all components in the pod as a library named 'app'
            config["app"] = AppModule#.pod
        }
    }


4. Then to render an efan component:    efanXtra.component(Overdue#).render(["Mr Smith"])




Full example source code available on [BitBucket](https://bitbucket.org/AlienFactory/afefanxtra/src/default/test/example/).

## Components

An efan component consists of a Fantom class (or mixin) that extends `EfanComponent` and a corresponding efan template file.

efanXtra does away with [efan's](http://eggbox.fantomfactory.org/pods/afEfan) `ctx` variable and instead lets the template access fields and methods of the component class directly.

### Classes

Component classes extend the [EfanComponent](http://eggbox.fantomfactory.org/pods/afEfanXtra/api/EfanComponent) mixin and may or may not be `const`.

efanXtra caches component instances where it can, so it may be advantageous to use const classes, espically if using a lot of IoC injection. `const` services may be injected as usual, and `abstract` render variables may be used for state.

Taking the [Overdue](#quickStart) component as an example:

    using afEfanXtra
    
    const class Overdue : EfanComponent {
    
        // standard service injection
        @Inject
        const DvdService? dvdService
    
        // render variables are mutable
        abstract Str? userName
    
        // standard it-block ctor for ioc injection
        new make(|This| f) { f(this) }
    
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
    

### Mixins

Component mixins extend the [EfanComponent](http://eggbox.fantomfactory.org/pods/afEfanXtra/api/EfanComponent) mixin and may or may not be `const`.

All fields and methods of the mixin are visible and directly accessible in the efan template. Fields, as per standard mixin contracts, must be `abstract`.

Components are created by [IoC](http://eggbox.fantomfactory.org/pods/afIoc) so feel free to annotate fields with `@Inject` just as you would with a service class.

See [Lifecycle Methods](#lifecycle) to see how to initialise and pass data into your components.

### Templates

By default, efan template files have the same name as the class, but with an `.efan` extension. If you wish the template to have a different name to the Fantom class, you can set an explicit URL with the [@TemplateLocation](http://eggbox.fantomfactory.org/pods/afEfanXtra/api/TemplateLocation) facet. Example:

    @TemplateLocation { url=`fan://acmePod/templates/Notice.efan` }
    class Overdue : EfanComponent {
        ...
    }
    

Note if you have a type hierarchy, and a template for the subclass isn't found, then templates are searched again but using the base class name.

#### Pod Templates

A template may be a pod resource. For example, if you were to create a component called `Layout`, you may have the following files:

    /fan/components/Layout.fan  --> the mixin class
    /res/components/Layout.efan --> the template file

For efanXtra to find the template file, be sure to add `/res/components/` as a `resDir` in your `build.fan`.

    resDirs = [`res/components/`]

> **ALIEN-AID:** Note resource directories in `build.fan` are NOT nested. Adding `res/` will **NOT** add `res/components/`.


#### File System Templates

Templates may also be kept on the file system. This can be very handy for development, as templates on the file system don't require the pod to be re-built (or the application re-started) when they change.

To do this, contribute to [TemplateDirectories](http://eggbox.fantomfactory.org/pods/afEfanXtra/api/TemplateDirectories) to tell efanXtra where to look for templates:

    const class AppModule {
    
        @Contribute { serviceType=TemplateDirectories# }
        Void contributeTemplateDirs(Configuration config) {
            config.add(`etc/components/`)
        }
    }
    

Note that like Fantom resource directories, template directories are NOT nested; adding `etc/` will **NOT** add `etc/components/`.

Also note that the directory URIs must end in a slash.

File system template are checked every 2min in production and every 2sec in development. To change these timings, add the following configuration:

    @Contribute { serviceType=ApplicationDefaults# }
    Void configureAppDefaults(Configuration config) {
        config["afEfanXtra.templateTimeout"] = 1min
    }
    

#### Fandoc Comment Templates

Templates may also be embedded in the fandoc comment of the component! Simply prefix the fandoc comment with `template:` followed by the type. Example:

    using afEfanXtra
    
    ** template: efan
    **
    ** Yo Dawg! Check <%= hello %>
    **
    class TemplateFromFandocComment : EfanComponent {
        Str hello() { "this out!" }
    }
    

Will render `Yo Dawg! Check this out!`

Or, if you want to embed the template inside the fandoc comment, use a `<pre>` tag:

    using afEfanXtra
    
    ** This is not rendered.
    **
    ** pre>
    ** template: efan
    **
    ** Yo Digidy! Check <%= hello %>
    ** <pre
    **
    ** Nor is this.
    class TemplateFromFandocComment : EfanComponent {
        Str hello() { "this out!" }
    }
    

Which will render `Yo Digidy! Check this out!`

This is useful for keeping everything together in small components where you don't want the inconvenience of an external template file.

## Libraries

Components are organised by libraries. A library encompasses all components within a pod. To use your efan components effectively, you should add your application pod as a library. Do this in your `AppModule`:

    using afIoc
    using afEfanXtra
    
    const class AppModule {
    
        @Contribute { serviceType=EfanLibraries# }
        Void contributeEfanLibs(Configuration config) {
    
            // contribute all components in this pod as a library called 'app'
            config["app"] = AppModule#.pod
        }
    }
    

Library classes are automatically injected as fields into your components. Library classes contain component render methods. In the [Quick Start Example](#quickStart), the library (in a field named `app`) would bave 2 render methods, available for use in your templates:

    app.renderOverdue(Str userName)
    app.renderSignOff(Str who)

This allows you to render components from within templates by calling `<libName>.render<ComponentName>(...)`. Example:

    <%= app.renderSignOff("The Management") %>

> **ALIEN-AID:** Library render methods are logged at registry startup so you don't have to remember the method signatures!


## <a name="lifecycle"></a>Lifecycle Methods

Components can be thought of as having a lifecycle for the duration of their render. Components can be made aware of the lifecycle by annotating callback methods with lifecycle facets. The lifecycle, and all state held in the component, only exists for the duration of the render.

![efanXtra Component Lifecycle](http://eggbox.fantomfactory.org/pods/afEfanXtra/doc/lifecycle.png)

### @InitRender

A method annotated with [@InitRender](http://eggbox.fantomfactory.org/pods/afEfanXtra/api/InitRender) will be called before any other. It allows you to initialise and prepare your component for rendering.

The `@InitRender` method may take any arguments, the signature will be mimicked by the containing library's render method. Example, if your `@InitRender` looks like:

    class MyComponent : EfanComponent {
    
        @InitRender
        Void initRender(Int x, Str y) { ... }
    }
    

then the library render method will look like:

    Obj? renderMyComponent(Int x, Str y, |->| bodyFunc := null) { ... }
    

This lets you pass any arguments you want into your components.

`@InitRender` methods may return `Bool`. If `true`, the template is rendered as usual. If `false`, then template rendering is skipped.

### @BeforeRender

A method annotated with [@BeforeRender](http://eggbox.fantomfactory.org/pods/afEfanXtra/api/BeforeRender) is invoked after `@InitRender` but before any template rendering. It may optionally take a `StrBuf` as a parameter, this will hold the contents of the current render buffer.

`@BeforeRender` methods may return `Bool`. If `true`, the template is rendered as usual. If `false`, then template rendering is skipped.

### @AfterRender

A method annotated with [@AfterRender](http://eggbox.fantomfactory.org/pods/afEfanXtra/api/AfterRender) is invoked after the template has rendered. It may optionally take a `StrBuf` as a parameter, this will hold the contents of the current render buffer.

`@AfterRender` methods may return `Bool`. If `true`, the template rendering ends. If `false`, template rendering is sent back to `@BeforeRender`. In this way, simple loops may be set up.

## Render Variables

Efan components can store state! Components may be `const` and they may be `mixins`, but they can still store variables that can be accessed and used by the rendering template. Taking the [Overdue](#quickStart) component as an example:

    using afEfanXtra
    
    const mixin Overdue : EfanComponent {
    
        // render variables may also be injected
        @Inject
        abstract DvdService? dvdService
    
        abstract Str? userName
    
        @InitRender
        Void initRender(Str userName) {
            this.userName = userName
        }
    }
    

`userName` is a render variable used by the efan template. Before `initRender()` is called, all render variables are reset to `null` (hence they need to be `nullable`). They may then be initialised during `initRender()`, and used and / or reset at any other point in the rendering lifecycle.

Note that state is *not* preserved between different renderings of the component.

