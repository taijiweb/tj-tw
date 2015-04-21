function Com(){

}

Com.prototype.render = function(){

}

function Proxy(){

}

Proxy.prototype.instanciate = function instanciate(){

}

function com(value){
  return new Com();
}

function Static(value){

}

function Duplex(){

}

function Lane(){

}

function Once(){

}

function Sequence(){

}

var makeLane = function (x) {
    return new Lane(x);
}

function Prop(name, value){

}

function Element(tag, attrs, children, text){

}

function link(proxy, model){
  for (var path in proxy.paths) {
      model.defineProperty(path)
      Object.defineProperty(model, path, {
          get: function() {
              console.log('get!');
              return temperature;
          },
          set: function(value) {
              path = value;
              archive.push({ val: temperature });
          }
      });

  }
}

function mount(proxy, dom){

}