# efanXtra

`efanXtra` is a [Fantom](http://fantom.org/) library for creating reusable [Embedded Fantom (efan)](https://bitbucket.org/AlienFactory/afefan) components. It pairs up Fantom classes and efan templates to encapsulate model / view behaviour.



## Install

Install `efanXtra` with the Fantom Respository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afEfanXtra

To use in a Fantom project, add a dependency to its `build.fan`:

    depends = ["sys 1.0", ..., "afEfanXtra 1.0+"]



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afEfanXtra/#overview).



## Quick Start

Overdue.efan:

    Dear <%= userName %>,

    It appears the following rented DVDs are overdue:

        <%= dvds.join(", ") %>

    Please return them at your convenience.

    <% app.renderSignOff("The Management") %>

Overdue.fan:

    using afIoc
    using afEfanXtra

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

    @SubModule { modules=[EfanXtraModule#]}
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

    efanXtra.render(Overdue#, "Mr Smith")
