package heat.ecs;

class World {
    var classComs = new Map<String, Map<EntityId, Dynamic>>();
    var enumComs = new Map<String, Map<EntityId, Dynamic>>();
    var dynComs = new Map<String, Map<EntityId, Dynamic>>();

    public var addedComSignal:heat.event.ISignal<EComChange>;
    public var removingComSignal:heat.event.ISignal<EComChange>;

    var addedComSignalEmitter = new heat.event.SignalEmitter<EComChange>();
    var removingComSignalEmitter = new heat.event.SignalEmitter<EComChange>();

    var lastIntId:Int = 0;

    public function new() {
        addedComSignal = addedComSignalEmitter.signal;
        removingComSignal = removingComSignalEmitter.signal;
    }

    public function getId():EntityId {
        return ++lastIntId;
    }

    public function registerCom<TClass, TEnum>
    (comType:ComType<TClass, TEnum>):World
    {
        switch comType {
            case CLASS(cls): {
                var name = Type.getClassName(cls);
                if (!classComs.exists(name)) {
                    classComs[name] = new Map<EntityId, TClass>();
                }
            }
            case ENUM(enm): {
                var name = Type.getEnumName(enm);
                if (!enumComs.exists(name)) {
                    enumComs[name] = new Map<EntityId, TEnum>();
                }
            }
            case DYN(typeId): {
                if (!dynComs.exists(typeId)) {
                    dynComs[typeId] = new Map<EntityId, Dynamic>();
                }
            }
        }
        return this;
    }

    public function getClassCom<T>
    (cls:Class<T>, id:EntityId):haxe.ds.Option<T>
    {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) return None;
        if (!classComs[name].exists(id)) return None;
        return Some(classComs[name][id]);
    }

    public function getClassComs<T>
    (cls:Class<T>):haxe.ds.Option<Map<EntityId, T>>
    {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) return None;
        return Some(cast classComs[name]);
    }

    public function getEnumCom<T>
    (enm:Enum<T>, id:EntityId):haxe.ds.Option<T>
    {
        var name = Type.getEnumName(enm);
        if (!enumComs.exists(name)) return None;
        if (!enumComs[name].exists(id)) return None;
        return Some(enumComs[name][id]);
    }

    public function getEnumComs<T>
        (enm:Enum<T>):haxe.ds.Option<Map<EntityId, T>>
        {
            var name = Type.getEnumName(enm);
            if (!enumComs.exists(name)) return None;
            return Some(cast enumComs[name]);
        }

    public function getDynCom(typeId:String, id:EntityId)
    :haxe.ds.Option<Dynamic> 
    {
        if (!dynComs.exists(typeId)) return None;
        if (!dynComs[typeId].exists(id)) return None;
        return Some(dynComs[typeId][id]);
    }

    public function getDynComs(typeId:String):haxe.ds.Option<Map<EntityId, Dynamic>> {
        if (!dynComs.exists(typeId)) return None;
        return Some(dynComs[typeId]);
    }

    public function setClassCom<T>(cls:Class<T>, id:EntityId, com:T):World {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) {
            trace('Tried to set class $name before registering it.');
            return this;
        }
        classComs[name][id] = com;
        addedComSignalEmitter.emit({
            id: id,
            comType: CLASS(cls)
        });
        return this;
    }

    public function setEnumCom<T>(enm:Enum<T>, id:EntityId, com:T):World {
        var name = Type.getEnumName(enm);
        if (!enumComs.exists(name)) {
            trace('Tried to set enum $name before registering it.');
            return this;
        }
        enumComs[name][id] = com;
        addedComSignalEmitter.emit({
            id: id,
            comType: ENUM(enm)
        });
        return this;
    }

    public function setDynCom(typeId:String, id:EntityId, com:Dynamic):World {
        if (!dynComs.exists(typeId)) {
            trace('Tried to set dyn com $typeId before registering it.');
            return this;
        }
        dynComs[typeId][id] = com;
        addedComSignalEmitter.emit({
            id: id,
            comType: DYN(typeId)
        });
        return this;
    }

    public function removeClassCom<T>(cls:Class<T>, id:EntityId):World {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) return this;
        if (!classComs[name].exists(id)) return this;
        removingComSignalEmitter.emit({
            id: id,
            comType: CLASS(cls)
        });
        classComs[name].remove(id);
        return this;
    }

    public function removeClassComs<T>(cls:Class<T>):World {
        var name = Type.getClassName(cls);
        if (!classComs.exists(name)) return this;
        for (id => com in classComs[name]) {
            removingComSignalEmitter.emit({
                id: id,
                comType: CLASS(cls)
            });
            classComs[name].remove(id);
        }
        return this;
    }

    public function removeEnumCom<T>(enm:Enum<T>, id:EntityId):World {
        var name = Type.getEnumName(enm);
        if (!enumComs.exists(name)) return this;
        if (!enumComs[name].exists(id)) return this;
        removingComSignalEmitter.emit({
            id: id,
            comType: ENUM(enm)
        });
        enumComs[name].remove(id);
        return this;
    }

    public function removeEnumComs<T>(enm:Enum<T>):World {
        var name = Type.getEnumName(enm);
        if (!enumComs.exists(name)) return this;
        for (id => com in enumComs[name]) {
            removingComSignalEmitter.emit({
                id: id,
                comType: ENUM(enm)
            });
            enumComs[name].remove(id);
        }
        return this;
    }

    public function removeDynCom(typeId:String, id:EntityId):World {
        if (!dynComs.exists(typeId)) return this;
        if (!dynComs[typeId].exists(id)) return this;
        removingComSignalEmitter.emit({
            id: id,
            comType: DYN(typeId)
        });
        dynComs[typeId].remove(id);
        return this;
    }

    public function removeDynComs(typeId:String):World {
        if (!dynComs.exists(typeId)) return this;
        for (id => com in dynComs[typeId]) {
            removingComSignalEmitter.emit({
                id: id,
                comType: DYN(typeId)
            });
            dynComs[typeId].remove(id);
        }
        return this;
    }

    public function removeAll():World {
        for (name => coms in classComs) {
            var cls = Type.resolveClass(name);
            for (id => com in coms) {
                removingComSignalEmitter.emit({
                    id: id,
                    comType: CLASS(cls)
                });
                coms.remove(id);
            }
        }
        for (name => coms in enumComs) {
            var enm = Type.resolveEnum(name);
            for (id => com in coms) {
                removingComSignalEmitter.emit({
                    id: id,
                    comType: ENUM(enm)
                });
                coms.remove(id);
            }
        }
        for (typeId => coms in dynComs) {
            for (id => com in coms) {
                removingComSignalEmitter.emit({
                    id: id,
                    comType: DYN(typeId)
                });
                coms.remove(id);
            }
        }        
        return this;
    }

    public function removeEntity(id:EntityId):World {
        for (name => coms in classComs) {
            var cls = Type.resolveClass(name);
            if (coms.exists(id)) {
                removingComSignalEmitter.emit({
                    id: id,
                    comType: CLASS(cls)
                });
                coms.remove(id);
            }
        }
        for (name => coms in enumComs) {
            var enm = Type.resolveEnum(name);
            if (coms.exists(id)) {
                removingComSignalEmitter.emit({
                    id: id,
                    comType: ENUM(enm)
                });
                coms.remove(id);
            }
        }
        for (typeId => coms in dynComs) {
            if (coms.exists(id)) {
                removingComSignalEmitter.emit({
                    id: id,
                    comType: DYN(typeId)
                });
                coms.remove(id);
            }
        }
        return this;
    }
}