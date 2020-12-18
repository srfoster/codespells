
var functions = {} //Global, so more functions can be defined via eval
var widgets = {}

//It's a philosophical question whether this should be part of the core/minimal Unreal runtime.
//  Might want to move it to some kind of "modding framework" module and have it evaled in by some Racket module.
//  We'll see.
functions.bpFromMod = function(dir,mod_name,blueprint_name){
                          class ModLoader extends Root.ResolveClass('ModLoader'){ }

                           let ModLoader_C = require('uclass')()(global,ModLoader)
                           let ml = new ModLoader_C(GWorld,{X:0,Y:0,Z:0})

                           var ret = ml.ClassFromMod(dir,mod_name,blueprint_name)

                           class BP extends ret.Class {}

                           let ret_C = require('uclass')()(global,BP)

                           ml.DestroyActor() //Maybe should keep it around and cache it?

                           return ret_C
}

//The minimal code to allow for Aether->World Crossing.
//  Currently based on Isara tech's webserver.  Will need to change this to become more cross platform.
function main(){
  console.log("**************Unreal Server Started************")

  class MyServer extends Root.ResolveClass('Server'){
     Eval(conn){
       console.log("In Eval(conn)")

       var script = conn.GetData()
      // var script = conn.GetGETVar("script")
       console.log("script",script)

       eval(script)

       var resp = new Response.ConstructResponseExt()
       resp.SetResponseContent("Thanks")
       conn.SendResponse(resp)

     }
  }

  let MyServer_C = require('uclass')()(global,MyServer)
  let s = new MyServer_C(GWorld,{X:7360.0,Y:3860.0,Z:7296.0},{Yaw:180})
  console.log("JS Server started!")

  // clean up the mess
  return function () {
    s.DestroyActor()
  }

}

// bootstrap to initiate live-reloading dev env.
try {
    module.exports = () => {
        let cleanup = null

        // wait for map to be loaded.
        process.nextTick(() => cleanup = main());

        // live-reloadable function should return its cleanup function
        return () => cleanup()
    }
}
catch (e) {
    console.log("Error",e);
    require('bootstrap')('on-start')
}
