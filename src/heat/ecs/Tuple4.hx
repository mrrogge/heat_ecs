package heat.ecs;

/**
    A mutable tuple structure with four elements.
**/
@:expose("Tuple4")
class Tuple4<T0, T1, T2, T3> {
    /** Element 0.**/
    public var e0:T0;
    /** Element 1.**/
    public var e1:T1;
    /** Element 2.**/
    public var e2:T2;
    /** Element 3.**/
    public var e3:T3;

    /**
        @param e0 Element 0.
        @param e1 Element 1.
        @param e2 Element 2.
        @param e3 Element 3.
    **/
    public function new(?e0:T0, ?e1:T1, ?e2:T2, ?e3:T3) {
        this.init(e0, e1, e2, e3);
    }

    /**
        @param e0 Element 0.
        @param e1 Element 1.
        @param e2 Element 2.
        @param e3 Element 3.
    **/   
    public inline function init(?e0:T0, ?e1:T1, ?e2:T2, ?e3:T3) {
        this.e0 = e0;
        this.e1 = e1;
        this.e2 = e2;
        this.e3 = e3;
    }
}