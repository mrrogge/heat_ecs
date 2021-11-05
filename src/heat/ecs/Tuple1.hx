package heat.ecs;

/**
    A mutable tuple structure with 1 element.
**/
@:expose("Tuple1")
class Tuple1<T0> {
    /** Element 0.**/
    public var e0:T0;

    /**
        @param e0 Element 0.
    **/
    public function new(?e0:T0) {
        this.init(e0);
    }

    /**
        @param e0 Element 0.
    **/
    public inline function init(?e0:T0) {
        this.e0 = e0;
    }
}