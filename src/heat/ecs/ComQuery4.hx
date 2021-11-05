package heat.ecs;

import haxe.ds.Either;

/**
    An implementation of `IComQuery` for four `ComMap`s.
**/
class ComQuery4<T0, T1, T2, T3> implements IComQuery {
    public var map0(default, null):IComMap<T0>;
    public var map1(default, null):IComMap<T1>;
    public var map2(default, null):IComMap<T2>;
    public var map3(default, null):IComMap<T3>;

    @:inheritDoc(IComQuery.result)
    public var result(default, null) = new Array<EntityId>();

    public function new(map0:IComMap<T0>, map1:IComMap<T1>, map2:IComMap<T2>, map3:IComMap<T3>) {
        this.map0 = map0;
        this.map1 = map1;
        this.map2 = map2;
        this.map3 = map3;
    }

    @:inheritDoc(IComQuery.run)
    public function run():Array<EntityId> {
        while (result.length > 0) result.pop();
        for (id in map0.keys()) {
            if (map1.exists(id) && map2.exists(id) && map3.exists(id)) {
                result.push(id);
            }
        }
        return this.result;
    }

    @:inheritDoc(IComQuery.hasAll)
    public function hasAll(id:EntityId):Bool {
        return map0.exists(id) && map1.exists(id) && map2.exists(id) && map3.exists(id);
    }

    /**
        Returns a `Tuple4` of components for a given `id` corresponding to the query's `ComMap`s. One or more components may be null if they do not exist for `id`.

        If a `tuple` argument is passed, the components will be applied to that instance and returned. Otherwise, a new `Tuple4` instance will be constructed and returned.

        @param id The entity identifier to check.

        @param tuple An existing tuple to reuse, if desired.
    **/
    public function getComTuple(id:EntityId, ?tuple:Tuple4<T0, T1, T2, T3>):Tuple4<T0, T1, T2, T3> {
        var returnedTuple = {
            if (tuple != null) tuple
            else new Tuple4();
        };
        returnedTuple.init(map0.get(id), map1.get(id), map2.get(id), map3.get(id));
        return returnedTuple;
    }
}