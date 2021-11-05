package heat.ecs;

import haxe.ds.Either;

class EntityQuery {
    var world:World;
    var criteria = new Array<EntityQueryCriterion>();

    var resultMap = new Map<EntityId, Bool>();
    public var result = new Array<EntityId>();

    public function new(world:World) {
        this.world = world;
    }

    public function with(clsOrEnum:EitherClassOrEnum<Dynamic, Dynamic>):EntityQuery 
    {
        switch clsOrEnum {
            case Left(cls): criteria.push(WITH_CLASS(cls));
            case Right(enm): criteria.push(WITH_ENUM(enm));
        }
        return this;
    }

    public function run() {
        resultMap.clear();
        for (i in 0...result.length) result.pop();
        if (criteria.length <= 0) return;
        var firstCriterion = criteria[0];
        var coms = switch firstCriterion {
            case WITH_CLASS(cls): world.getClassComs(cls);
            case WITH_ENUM(enm): world.getEnumComs(enm);
        }
        switch coms {
            case Some(coms): {
                for (id => com in coms) {
                    resultMap[id] = true;
                }
            }
            case None: return;
        }
        if (criteria.length > 1) {
            for (id => _ in resultMap) {
                for (i in 1...criteria.length) {
                    var criterion = criteria[i];
                    var coms = switch criterion {
                        case WITH_CLASS(cls): world.getClassComs(cls);
                        case WITH_ENUM(enm): world.getEnumComs(enm);
                    }
                    switch coms {
                        case Some(coms): {
                            if (!coms.exists(id)) {
                                resultMap.remove(id);
                                break;
                            }
                        }
                        case None: return;
                    }
                }
            }
        }
        for (id => _ in resultMap) {
            result.push(id);
        }
    }

    public function matches(id:EntityId):Bool {
        for (criterion in criteria) {
            switch criterion {
                case WITH_CLASS(cls): {
                    switch world.getClassCom(cls, id) {
                        case Some(com): {}
                        case None: return false;
                    }
                }
                case WITH_ENUM(enm): {
                    switch world.getEnumCom(enm, id) {
                        case Some(enm): {}
                        case None: return false;
                    }
                }
            }
        }
        return true;
    }
}