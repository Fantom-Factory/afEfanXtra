using afIoc

@Component
const mixin Overdue {

  // use afIoc services!
  @Inject abstract DvdService? dvdService

  // access fields from the template
  abstract Str? userName

  // called before the component is rendered
  Void initialise(Str userName) {
     this.userName = userName
   }

   // methods may be called from the template
   Str[] dvds() {
     dvdService.findByName(userName)
   }
}