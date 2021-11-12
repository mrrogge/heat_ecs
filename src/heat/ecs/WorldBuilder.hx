package heat.ecs;

import haxe.macro.Context;

using haxe.macro.TypeTools;
using haxe.macro.ExprTools;
using haxe.macro.ComplexTypeTools;
using StringTools;

class WorldBuilder {
    static var worldLabelIdxMap = new Map<String, Int>();
    static var worldTypeLabelMap = new Map<String, Map<String, String>>();

    static var structMap = new Map<String, String>();
    static var structIndex = 0;
    static var labelIndex = 0;

    public static macro function build():Array<haxe.macro.Expr.Field> {
        var fields = haxe.macro.Context.getBuildFields();

        var worldClass = Context.getLocalClass();
        var worldClassId = worldClass.toString().replace(".", "_");

        if (worldLabelIdxMap.exists(worldClassId)) return fields;
        else {
            worldLabelIdxMap[worldClassId] = 0;
        }

        if (worldTypeLabelMap.exists(worldClassId)) return fields;
        else {
            worldTypeLabelMap[worldClassId] = new Map<String, String>();
        }

        //build the ComLabel enum type
        var comLabelDef:haxe.macro.Expr.TypeDefinition = {
            pack: [],
            name: 'ComLabel_$worldClassId',
            pos: Context.currentPos(),
            kind: TDEnum,
            fields: []
        }
        Context.defineType(comLabelDef);
        var comLabelType:haxe.macro.Expr.ComplexType = TPath({
            pack: [],
            name: 'ComLabel_$worldClassId'
        });

        //build the ComOptionImpl enum type
        var comOptionImplDef:haxe.macro.Expr.TypeDefinition = {
            pack: [],
            name: 'ComOptionImpl_$worldClassId',
            pos: Context.currentPos(),
            kind: TDEnum,
            fields: []
        }
        Context.defineType(comOptionImplDef);
        var comOptionImplType:haxe.macro.Expr.ComplexType = TPath({
            pack: [],
            name: 'ComOptionImpl_$worldClassId'
        });

        //build the ComOption abstract type
        var comOptionDef:haxe.macro.Expr.TypeDefinition = {
            pack: [],
            name: 'ComOption_$worldClassId',
            pos: Context.currentPos(),
            kind: TDAbstract(comOptionImplType, [comOptionImplType], 
                [comOptionImplType]
            ),
            fields: []
        }
        Context.defineType(comOptionDef);
        var comOptionType:haxe.macro.Expr.ComplexType = TPath({
            pack: [],
            name: 'ComOption_$worldClassId'
        });

        //build the getCom() method
        var getComRetType:haxe.macro.Expr.ComplexType = TPath({
            pack: ["haxe", "ds"],
            name: "Option",
            params: [TPType(comOptionType)]
        });
        var getComDef:haxe.macro.Expr.Field = {
            name: "getCom",
            access: [APublic],
            kind: haxe.macro.Expr.FieldType.FFun({
                args: [
                    {
                        name: "id",
                        opt: false,
                        type: macro : heat.ecs.EntityId
                    },
                    {
                        name: "label",
                        opt: false,
                        type: comLabelType
                    }
                ],
                ret: getComRetType,
                expr: {
                    expr: EReturn({
                        expr: ESwitch(
                            {
                                expr: EConst(CIdent("label")),
                                pos: Context.currentPos()
                            },
                            [],
                            macro $v{haxe.ds.Option.None}
                        ),
                        pos: Context.currentPos()
                    }),
                    pos: Context.currentPos()
                }
            }),
            pos: Context.currentPos()
        }
        fields.push(getComDef);

        //build the setCom() method
        var setComDef:haxe.macro.Expr.Field = {
            name: "setCom",
            access: [APublic],
            kind: haxe.macro.Expr.FieldType.FFun({
                args: [
                    {
                        name: "id",
                        opt: false,
                        type: macro : heat.ecs.EntityId
                    },
                    {
                        name: "com",
                        opt: false,
                        type: comOptionType
                    }
                ],
                expr: {
                    expr: ESwitch(
                        {
                            expr: EConst(CIdent("com")),
                            pos: Context.currentPos()
                        },
                        [],
                        macro $b{[]}
                    ),
                    pos: Context.currentPos()
                }
            }),
            pos: Context.currentPos()
        }
        fields.push(setComDef);

        return fields;
    }

    public static macro function registerComType<T>
    (item:haxe.macro.Expr.ExprOf<T>, ?label:String):Array<haxe.macro.Expr.Field> {
        var fields = haxe.macro.Context.getBuildFields();
        if (label == null) label = 'T${labelIndex++}';
        trace(label);
        var itemType = haxe.macro.Context.typeof(item).toComplexType();
        var typeId:Null<String> = null;
        switch itemType {
            case TAnonymous(fields): {
                typeId = itemType.toString();
                if (structMap.exists(typeId)) typeId = structMap[typeId];
                else {
                    structMap[typeId] = '_struct${structIndex++}';
                    typeId = structMap[typeId];
                }
            }
            default: typeId = itemType.toString().replace(".", "_");
        }
        trace('registering type: $typeId...');
        var mapType:haxe.macro.Expr.ComplexType = TPath({
            name: "Map",
            params: [TPType(macro : heat.ecs.EntityId), TPType(itemType)],
            pack: []
        });
        var mapExpr:haxe.macro.Expr = {
            expr: ENew({
                name: "Map",
                params: [TPType(macro : heat.ecs.EntityId), TPType(itemType)],
                pack: []
            }, []),
            pos: haxe.macro.Context.currentPos()
        }
        fields.push({
            name: '_comMap_$typeId',
            kind: FVar(mapType, mapExpr),
            pos: haxe.macro.Context.currentPos()
        });

        // modify getCom()
        var cls = haxe.macro.Context.getLocalClass().get();
        var getComExpr = cls.findField("getCom");

        return fields;
    }
}