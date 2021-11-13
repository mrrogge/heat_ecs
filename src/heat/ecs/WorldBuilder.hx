package heat.ecs;

import haxe.macro.Context;

using haxe.macro.TypeTools;
using haxe.macro.ExprTools;
using haxe.macro.ComplexTypeTools;
using StringTools;
using haxe.macro.TypedExprTools;

class WorldBuilder {
    static var worldLabelIdxMap = new Map<String, Int>();
    static var worldTypeToLabelMap = new Map<String, Map<String, String>>();
    static var worldLabelToTypeMap = new Map<String, Map<String, String>>();
    static var worldTypeLabels = new Map<String, Map<String, Bool>>();

    static var worldComLabelDefs = new Map<String, haxe.macro.Expr.TypeDefinition>();
    static var worldComOptionImplDefs = new Map<String, haxe.macro.Expr.TypeDefinition>();
    static var worldComOptionDefs = new Map<String, haxe.macro.Expr.TypeDefinition>();
    static var worldGetComFieldDefs = new Map<String, haxe.macro.Expr.Field>();
    static var worldGetComCaseArrays = new Map<String, Array<haxe.macro.Expr.Case>>();
    static var worldSetComFieldDefs = new Map<String, haxe.macro.Expr.Field>();
    static var worldSetComCaseArrays = new Map<String, Array<haxe.macro.Expr.Case>>();

    public static macro function build():Array<haxe.macro.Expr.Field> {
        var fields = haxe.macro.Context.getBuildFields();

        var worldClass = Context.getLocalClass();
        var worldClassId = worldClass.toString().replace(".", "_");

        if (worldLabelIdxMap.exists(worldClassId)) return fields;
        else {
            worldLabelIdxMap[worldClassId] = 0;
        }

        if (worldTypeToLabelMap.exists(worldClassId)) return fields;
        else {
            worldTypeToLabelMap[worldClassId] = new Map<String, String>();
        }

        if (worldLabelToTypeMap.exists(worldClassId)) return fields;
        else {
            worldLabelToTypeMap[worldClassId] = new Map<String, String>();
        }

        if (worldTypeLabels.exists(worldClassId)) return fields;
        else {
            worldTypeLabels[worldClassId] = new Map<String, Bool>();
        }

        if (worldGetComCaseArrays.exists(worldClassId)) return fields;
        else {
            worldGetComCaseArrays[worldClassId] = new Array<haxe.macro.Expr.Case>();
        }

        if (worldSetComCaseArrays.exists(worldClassId)) return fields;
        else {
            worldSetComCaseArrays[worldClassId] = new Array<haxe.macro.Expr.Case>();
        }

        //build the ComLabel enum type
        var comLabelDef:haxe.macro.Expr.TypeDefinition = {
            pack: [],
            name: 'ComLabel_$worldClassId',
            pos: Context.currentPos(),
            kind: TDEnum,
            fields: []
        }
        var comLabelType:haxe.macro.Expr.ComplexType = TPath({
            pack: [],
            name: 'ComLabel_$worldClassId'
        });
        worldComLabelDefs[worldClassId] = comLabelDef;

        //build the ComOptionImpl enum type
        var comOptionImplDef:haxe.macro.Expr.TypeDefinition = {
            pack: [],
            name: 'ComOptionImpl_$worldClassId',
            pos: Context.currentPos(),
            kind: TDEnum,
            fields: []
        }
        var comOptionImplType:haxe.macro.Expr.ComplexType = TPath({
            pack: [],
            name: 'ComOptionImpl_$worldClassId'
        });
        worldComOptionImplDefs[worldClassId] = comOptionImplDef;

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
        var comOptionType:haxe.macro.Expr.ComplexType = TPath({
            pack: [],
            name: 'ComOption_$worldClassId'
        });
        worldComOptionDefs[worldClassId] = comOptionDef;

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
                            worldGetComCaseArrays[worldClassId],
                            null
                        ),
                        pos: Context.currentPos()
                    }),
                    pos: Context.currentPos()
                }
            }),
            pos: Context.currentPos()
        }
        worldGetComFieldDefs[worldClassId] = getComDef;
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
                        worldSetComCaseArrays[worldClassId],
                        macro $b{[]}
                    ),
                    pos: Context.currentPos()
                }
            }),
            pos: Context.currentPos()
        }
        worldSetComFieldDefs[worldClassId] = setComDef;
        fields.push(setComDef);

        Context.onTypeNotFound(s -> {
            return if (s == 'ComLabel_$worldClassId') {
                trace('building $s');
                worldComLabelDefs[worldClassId];
            }
            else if (s == 'ComOptionImpl_$worldClassId') {
                trace('building $s');
                worldComOptionImplDefs[worldClassId];
            }
            else if (s == 'ComOption_$worldClassId') {
                trace('building $s');
                worldComOptionDefs[worldClassId];
            }
            else {
                // trace('unknown type: $s');
                null;
            }
        });

        return fields;
    }

    public static macro function registerComType<T>
    (item:haxe.macro.Expr.ExprOf<T>, ?label:String):Array<haxe.macro.Expr.Field> {
        var fields = haxe.macro.Context.getBuildFields();
        
        var worldClass = Context.getLocalClass();
        var worldClassId = worldClass.toString().replace(".", "_");

        if (label == null) {
            label = 'T${worldLabelIdxMap[worldClassId]++}';
        }
        var itemType = haxe.macro.Context.typeof(item).toComplexType();
        var itemTypeId = itemType.toString();
        if (worldTypeToLabelMap[worldClassId].exists(itemTypeId) 
        || worldLabelToTypeMap[worldClassId].exists(label)) 
        {
            throw Context.error('Type "$itemTypeId" already registered to a label.', Context.currentPos());
        }
        worldTypeToLabelMap[worldClassId][itemTypeId] = label;
        worldLabelToTypeMap[worldClassId][label] = itemTypeId;
        if (worldTypeLabels[worldClassId].exists(label)) {
            throw Context.error('Duplicate label "$label"; labels must be unique.', Context.currentPos());
        }
        worldTypeLabels[worldClassId][label] = true;

        trace('registering type: $itemTypeId...');

        //add map for storing coms
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
            name: '_comMap_$label',
            kind: FVar(mapType, mapExpr),
            pos: haxe.macro.Context.currentPos()
        });

        //modify ComLabel enum
        var comLabelType = worldComLabelDefs[worldClassId];
        comLabelType.fields.push({
            name: label,
            kind: FFun({
                args: []
            }),
            pos: Context.currentPos()
        });

        //modify ComOptionImpl enum
        var comOptionImplType = worldComOptionImplDefs[worldClassId];
        comOptionImplType.fields.push({
            name: label,
            kind: FFun({
                args: [
                    {
                        name: "com",
                        type: itemType
                    }
                ]
            }),
            pos: Context.currentPos()
        });

        //modify ComOption abstract
        var comOptionType = worldComOptionDefs[worldClassId];
        comOptionType.fields.push({
            name: 'from$label',
            access: [APublic, AStatic, AInline],
            kind: FFun({
                args: [{
                    name: "com",
                    type: itemType
                }],
                ret: TPath({
                    pack: [],
                    name: comOptionType.name
                }),
                expr: {
                    expr: EReturn({
                        expr: ECall(
                            {
                                expr: EField(
                                    {
                                        expr: EConst(
                                            CIdent(comOptionImplType.name)
                                        ),
                                        pos: Context.currentPos()
                                    },
                                    label
                                ),
                                pos: Context.currentPos()
                            },
                            [{
                                expr: EConst(CIdent("com")),
                                pos: Context.currentPos()
                            }]
                        ),                        
                        pos: Context.currentPos()
                    }),
                    pos: Context.currentPos()
                }
            }),
            pos: Context.currentPos(),
            meta: [{
                name: ":from",
                pos: Context.currentPos()
            }]
        });

        comOptionType.fields.push({
            name: 'to$label',
            access: [AInline, APublic],
            pos: Context.currentPos(),
            meta: [{
                name: ":to",
                pos: Context.currentPos()
            }],
            kind: FFun({
                args: [],
                ret: itemType,
                expr: {
                    pos: Context.currentPos(),
                    expr: EReturn({
                        pos: Context.currentPos(),
                        expr: ESwitch(
                            macro $i{"this"}, 
                            [{
                                values: [{
                                    pos: Context.currentPos(),
                                    expr: ECall(
                                        macro $i{label},
                                        [macro $i{"com"}]
                                    )
                                }],
                                expr: macro $i{"com"}
                            }],
                            macro $i{"null"}
                        )
                    })
                }
            })
        });

        // modify getCom()
        var getComCases = worldGetComCaseArrays[worldClassId];
        getComCases.push({
            values: [macro $i{label}],
            expr: {
                pos: Context.currentPos(),
                expr: ETernary(
                    {
                        pos: Context.currentPos(),
                        expr: EBinop(
                            OpEq, 
                            {
                                pos: Context.currentPos(),
                                expr: EArray(
                                    macro $i{'_comMap_$label'},
                                    macro $i{"id"}
                                )
                            },
                            macro $i{"null"}
                        )
                    },
                    macro $i{"None"},
                    {
                        pos: Context.currentPos(),
                        expr: ECall(
                            macro $i{"Some"},
                            [{
                                pos: Context.currentPos(),
                                expr: EArray(
                                    macro $i{'_comMap_$label'},
                                    macro $i{"id"}
                                )
                            }]
                        )
                    }
                )
            }
        });
        for (field in fields) {
            if (field.name == "getCom") {
                fields.remove(field);
                fields.push(worldGetComFieldDefs[worldClassId]);
                break;
            }
        }

        //modify setCom()
        var setComCases = worldSetComCaseArrays[worldClassId];
        setComCases.push({
            values: [
                {
                    pos: Context.currentPos(),
                    expr: ECall(
                        {
                            pos: Context.currentPos(),
                            expr: EField(
                                macro $i{'ComOptionImpl_$worldClassId'},
                                label
                            )
                        },
                        [macro $i{"com"}]
                    )
                }
            ],
            expr: {
                pos: Context.currentPos(),
                expr: EBinop(
                    OpAssign,
                    {
                        pos: Context.currentPos(),
                        expr: EArray(
                            macro $i{'_comMap_$label'},
                            macro $i{"id"}
                        )
                    },
                    macro $i{"com"}
                )
            }           
        });
        for (field in fields) {
            if (field.name == "setCom") {
                fields.remove(field);
                fields.push(worldSetComFieldDefs[worldClassId]);
                break;
            }
        }

        return fields;
    }
}