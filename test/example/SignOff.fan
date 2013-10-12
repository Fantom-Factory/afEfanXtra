
@Component
const mixin SignOff {

  abstract Str? who

  Void initialise(Str who) {
     this.who = who
   }
}