package heat.ecs;

import haxe.ds.Either;

/**
    Underlying type for `ComMap`. Included here for completeness; there is no need to use this class directly.
**/
@:allow(heat.ecs.ComMapKeyIterator)
class ComMapInternal<T> implements IComMap<T> {
    /**
        Holds component instances that are mapped to `Int` `EntityId`s.
    **/
    var iMap = new Map<Int, T>();
    /**
        Contains every `Int` key currently in `iMap`. Allows stateless iteration of those keys without needing to build a `keys()` iterator.
    **/
    var iArray = new Array<Null<Int>>();
    /**
        Holds component instances that are mapped to `String` `EntityId`s.
    **/
    var sMap = new Map<String, T>();
    /**
        Contains every `String` key currently in `sMap`. Allows stateless iteration of those keys without needing to build a `keys()` iterator.
    **/
    var sArray = new Array<String>();

    /**
        The internal key iterator instance. This iterator gets reused, rather than building and throwing one away each loop. Because `ComMap` will likely be iterating within a game loop, this helps prevent unnecessary garbage collection cycles.
    **/
    var _keys:ComMapKeyIterator<T>;

    public function new() {
        _keys = new ComMapKeyIterator(this);
    }

    @:inheritDoc(IComMap.get)
    public function get(id:EntityId):Null<T> {
        switch (id) {
            case Left(strId): {
                return this.sMap[strId];
            }
            case Right(intId): {
                return this.iMap[intId];
            }
        }
    }

    /**
        See `ComMap.set`.
    **/
    public function set(id:EntityId, com:T):Void {
        switch (id) {
            case Left(strId): {
                if (com == null) {
                    if (this.sMap[strId] != null) {
                        this.sArray.remove(strId);
                    }
                    else {/* already removed */}
                }
                else {
                    if (this.sMap[strId] == null) {
                        this.sArray.push(strId);
                    }
                    else { /* already added */}
                }
                this.sMap[strId] = com;
            }
            case Right(intId): {
                if (com == null) {
                    if (this.iMap[intId] != null) {
                        this.iArray.remove(intId);
                    }
                    else {/* already removed */}
                }
                else {
                    if (this.iMap[intId] == null) {
                        this.iArray.push(intId);
                    }
                    else { /* already added */}
                }
                this.iMap[intId] = com;
            }
        }
    }

    /**
        Removes a component instance for a given `id`.
        @param id The `EntityId` key.
    **/
    inline public function remove(id:EntityId):Void {
        return this.set(id, null);
    }

    @:inheritDoc(IComMap.exists)
    public function exists(id:EntityId):Bool {
        switch (id) {
            case Left(strId): {
                return this.sMap[strId] != null;
            }
            case Right(intId): {
                return this.iMap[intId] != null;
            }
        }
    }

    @:inheritDoc(IComMap.keys)
    public function keys():Iterator<EntityId> {
        return _keys;
    }
}

/**
    A map of `EntityId`s to component instances. Components can be any type (specified by the `T` parameter).
**/
@:forward
@:forward.new
abstract ComMap<T>(ComMapInternal<T>) from ComMapInternal<T> to ComMapInternal<T> {
    @:inheritDoc(IComMap.get)
    @:arrayAccess
    public inline function getCom(id:EntityId) {
        return this.get(id);
    }

    /**
        Sets a component instance `com` for a given `id`.
        If a component already exists, it is replaced by the new `com`.
        @param id The `EntityId key.
        @param com The component instance.
    **/
    @:arrayAccess
    public inline function setCom(id:EntityId, com:T) {
        return this.set(id, com);
    }
}

private class ComMapKeyIterator<T> {
    var map:ComMap<T>;
    var i = 0;
    var state:ComMapKeyIteratorState = INTS;

    public function new(map:ComMap<T>) {
        this.map = map;
    }

    inline function checkIfEmpty() {
        switch state {
            case EMPTY: {
                if (map.iArray.length > 0 || map.sArray.length > 0) {
                    state = INTS;
                }
            }
            default: {
                if (map.iArray.length == 0 && map.sArray.length == 0) {
                    state = EMPTY;
                }
            }
        }
    }

    inline function checkNextInt():haxe.ds.Option<Int> {
        if (map.iArray.length == 0) return None;
        if (map.iArray[i] == null) return None;
        return Some(map.iArray[i]);
    }

    inline function checkNextString():haxe.ds.Option<String> {
        if (map.sArray.length == 0) return None;
        if (map.sArray[i] == null) return None;
        return Some(map.sArray[i]);
    }

    public function hasNext():Bool {
        checkIfEmpty();
        switch state {
            case EMPTY: return false;
            case DONE: {
                state = INTS;
                i = 0;
                return false;
            }
            default: return true;
        }
    }

    public function next():EntityId {
        var id:EntityId = null;
        while (true) {
            switch state {
                case INTS: {
                    switch checkNextInt() {
                        case Some(int): {
                            if (id == null) {
                                id = int;
                                i++;
                            }
                            else break;
                        }
                        case None: {
                            state = STRINGS;
                            i = 0;
                        }
                    }
                }
                case STRINGS: {
                    switch checkNextString() {
                        case Some(str): {
                            if (id == null) {
                                id = str;
                                i++;
                            }
                            else break;
                        }
                        case None: {
                            state = DONE;
                            i = 0;
                        }
                    }
                }
                case EMPTY, DONE: break;
            }
        }
        if (id == null) throw new haxe.Exception("problem with iteration");
        return id;
    }

    public inline function iterator():ComMapKeyIterator<T> {
        return this;
    }
}

private enum abstract ComMapKeyIteratorState(Int) {
    var INTS;
    var STRINGS;
    var DONE;
    var EMPTY;
}