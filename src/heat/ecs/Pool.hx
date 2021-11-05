package heat.ecs;

/**
    A generic object pool.

    To construct a `Pool` instance, there are three things you must define - an element type (`TElement`), a data type (`TData`), and a constructor function (constructor argument in `new`). 
        
    `TElement` is the type of object that will be pooled. This can be any type, although it is intended mainly for classes and anonymous structures.

    `TData` defines relevant data for the `TElement` instances. It is used to construct new `TElement`s and initialize previously-constructed instances.

    The constructor function accepts an instance of `TData` and returns an instance of `TElement`. When a new `TElement` is requested from an empty pool, this constructor function is called and the result is returned. The constructor is often just a wrapper around a `new TElement()` call, passing values from the `TData` into the "inner" constructor's arguments (if any). This abstraction allows us to pool any class type, regardless of their actual constructor arguments, without resorting to a subclass of `Pool`.

    An optional init function can be passed as well. This accepts a `TElement` and a `TData`, and is intended to apply the `TData` values onto the `TElement`. This is used when retrieving an existing `TElement` from the `Pool` such that the `TElement` is reset to a known initial state.
**/
class Pool<TElement, TData> {
    var stack = new haxe.ds.GenericStack<TElement>();
    var _constructor:(?data:TData)->TElement;
    
    @:allow(heat.ecs.ComStoreInternal)
    var _init:(instance:TElement, ?data:TData)->Void;

    function defaultInit(instance:TElement, ?data:TData):Void {}

    /**
        Constructs a new `Pool` instance.

        @param constructor The function used to construct new `TElement`s.
        @param init The function used to initialize existing `TElement`s.
    **/
    public function new(constructor:(?data:TData)->TElement, 
    ?init:(instance:TElement, ?data:TData)->Void) {
        this._constructor = constructor;
        this._init = (init == null) ? defaultInit : init;
    }

    /**
        Retrieves a `TElement` from the pool.

        If the pool is empty, a new `TElement` will be returned using the constructor function. Otherwise, an existing `TElement` is removed from the pool, initialized, then returned.

        @param data The data used to either construct or initialize the returned `TElement`.
    **/
    public function get(?data:TData):TElement {
        if (stack.isEmpty()) {
            return _constructor(data);
        }
        else {
            var instance = stack.pop();
            _init(instance, data);
            return instance;
        }
    }

    /**
        Adds an element to the pool. Once an element is returned, it must no longer be referenced in code, otherwise conflicts may occur.

        @param element The element to add.
    **/
    public inline function put(element:TElement) {
        stack.add(element);
    }

    /**
        Removes all instances from the pool.
    **/
    public function flush() {
        while (!stack.isEmpty()){
            stack.pop();
        }
    }
}