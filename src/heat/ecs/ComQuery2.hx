package heat.ecs;

import haxe.ds.Either;

/**
    An implementation of `IComQuery` for two `ComMap`s.
**/
class ComQuery2<T0, T1> implements IComQuery {
    public var map0(default, null):IComMap<T0>;
    public var map1(default, null):IComMap<T1>;

    @:inheritDoc(IComQuery.result)
    public var result(default, null) = new Array<EntityId>();

    public function new(map0:IComMap<T0>, map1:IComMap<T1>) {
        this.map0 = map0;
        this.map1 = map1;
    }

    @:inheritDoc(IComQuery.run)
    public function run():Array<EntityId> {
        while (result.length > 0) result.pop();
        for (id in map0.keys()) {
            if (map1.exists(id)) {
                result.push(id);
            }
        }
        return this.result;
    }

    @:inheritDoc(IComQuery.hasAll)
    public function hasAll(id:EntityId):Bool {
        return map0.exists(id) && map1.exists(id);
    }

    /**
        Returns a `Tuple2` of components for a given `id` corresponding to the query's `ComMap`s. One or more components may be null if they do not exist for `id`.

        If a `tuple` argument is passed, the components will be applied to that instance and returned. Otherwise, a new `Tuple2` instance will be constructed and returned.

        @param id The entity identifier to check.

        @param tuple An existing tuple to reuse, if desired.
    **/
    public function getComTuple(id:EntityId, ?tuple:Tuple2<T0, T1>):Tuple2<T0, T1> {
        var returnedTuple = {
            if (tuple != null) tuple
            else new Tuple2();
        };
        returnedTuple.init(map0.get(id), map1.get(id));
        return returnedTuple;
    }
}