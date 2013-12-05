
@NoDoc
@Component
const mixin SignOff {

  abstract Str? who

  Void initRender(Str who) {
     this.who = who
   }
}