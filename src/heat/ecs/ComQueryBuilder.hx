package heat.ecs;

import haxe.macro.Context;

#if macro
class ComQueryBuilder {
    public static function build(arity:Int):Void {
        try {
            Context.getType('heat.ecs.ComQueryAlt$arity');
        }
        catch (e:String) {
            //The map fields for each set of coms
            var fields:Array<haxe.macro.Expr.Field> = [for (i in 0...arity) {
                name: 'map$i',
                access: [APublic, ],
                kind:FProp("default", "null", TPath({
                    pack: [],
                    name: "Map",
                    params: [TPType(macro : heat.ecs.EntityId), TPType(TPath({
                        pack: [],
                        name: 'T$i'
                    }))]
                })),
                pos: Context.currentPos()
            }];
            //The result field, array of found IDs
            fields.push({
                name: "result",
                access: [APublic],
                kind: FProp("default", "null", macro : Array<EntityId>, macro new Array<EntityId>()),
                pos: Context.currentPos()
            });
            //The constructor
            fields.push({
                pos: Context.currentPos(),
                name: "new",
                access: [APublic],
                kind: FFun({
                    args: [for (i in 0...arity) {
                        name: 'map$i',
                        type: TPath({
                            pack: [],
                            name: "Map",
                            params: [TPType(macro : EntityId), TPType(TPath({
                                pack: [],
                                name: 'T$i'
                            }))]
                        })
                    }],
                    expr: {
                        pos: Context.currentPos(),
                        expr: EBlock([for (i in 0...arity) {
                            pos: Context.currentPos(),
                            expr: EBinop(OpAssign, 
                                {
                                    pos: Context.currentPos(),
                                    expr: EField(macro $i{"this"}, 'map$i')
                                },
                                macro $i{'map$i'}
                            )
                        }])
                    }
                })
            });

            var clsDef:haxe.macro.Expr.TypeDefinition = {
                pos: Context.currentPos(),
                name: 'ComQueryAlt$arity',
                pack: ["heat", "ecs"],
                kind:TDClass(),
                params: [for (i in 0...arity) {name: 'T$i'}],
                fields: fields
            };
            Context.defineModule('heat.ecs.ComQueryAlt$arity',
                [clsDef]
            );
        }
    }

    public static function buildUpTo(arity:Int):Void {
        for (i in 1...arity+1) {
            build(i);
        }
    }
}
#end