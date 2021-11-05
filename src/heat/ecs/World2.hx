package heat.ecs;

import haxe.macro.Expr;

class World2 {
    public function new() {

    }

    public macro function registerComType(e:Expr):Expr {
        var t = macro : TestType;
        
    }
}

typedef TestType = {};