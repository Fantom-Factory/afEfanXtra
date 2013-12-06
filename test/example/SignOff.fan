
@NoDoc
const mixin SignOff : EfanComponent {

  abstract Str? who

  Void initRender(Str who) {
     this.who = who
   }
}