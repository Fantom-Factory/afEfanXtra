# EfanExtra

`afEfanExtra` is a [Fantom](http://fantom.org/) library for creating reusable [Embedded Fantom (efan)](https://bitbucket.org/AlienFactory/afefan) components. It pairs up Fantom classes and efan templates 
to encapsulate model / view behaviour.



## Quick Start

Overdue.efan:

    Dear <%= userName %>,

    It appears the following rented DVDs are overdue:

        <%= dvds.join(", ") %>

    Please return them at your convenience.

    <% app.renderSignOff("The Management") %>

Overdue.fan:

    using afIoc
    using afEfanExtra

    @Component
    const mixin Overdue {

      // use afIoc services!
      @Inject abstract DvdService? dvdService

      // access fields from the template
      abstract Str? userName

      // called before the component is rendered
      Void initRender(Str userName) {
        this.userName = userName
      }

      // methods may be called from the template
      Str[] dvds() {
        dvdService.findByName(userName)
      }
    }

AppModule.fan:

    using afIoc

    @SubModule { modules=[EfanExtraModule#]}
    class AppModule {

      static Void bind(ServiceBinder binder) {
        binder.bindImpl(DvdService#)
      }

      @Contribute { serviceType=EfanLibraries# }
      static Void contributeEfanLibraries(MappedConfig config) {

        // contribute all components in our pod as a library named 'app'
        config["app"] = AppModule#.pod
      }
    }

Then to render a component:

    efanExtra.render(Overdue#, "Mr Smith")



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afEfanExtra/#overview).



## Install

Download from [status302](http://repo.status302.com/browse/afEfanExtra).

Or install via fanr:

    $ fanr install -r http://repo.status302.com/fanr/ afEfanExtra

To use in a project, add a dependency in your `build.fan`:

    depends = ["sys 1.0", ..., "afEfanExtra 0+"]
