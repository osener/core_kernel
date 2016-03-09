(** List operations.

    OCaml's lists are immutable, singly-linked lists, which therefore give fast access to
    the front of the list, and slow (i.e., O(n)) access to the back of the list.  The
    comparison functions on lists are lexicographic.
*)

type 'a t = 'a list [@@deriving bin_io, compare, sexp, typerep]

include Container.S1      with type 'a t := 'a t
include Monad.S           with type 'a t := 'a t
include Quickcheckable.S1 with type 'a t := 'a t

(** [of_list] is the identity function.  It is useful so that the [List] module matches
    the same signature that other container modules do, namely:

    {[
      val of_list : 'a List.t -> 'a t
    ]}
*)
val of_list : 'a t -> 'a t

val nth : 'a t -> int -> 'a option

(** Return the [n]-th element of the given list.
    The first element (head of the list) is at position 0.
    Raise if the list is too short or [n] is negative. *)
val nth_exn : 'a t -> int -> 'a

(** List reversal. *)
val rev : 'a t -> 'a t

(** [List.rev_append l1 l2] reverses [l1] and concatenates it to [l2].  This is equivalent
    to [(]{!List.rev}[ l1) @ l2], but [rev_append] is more efficient. *)
val rev_append : 'a t -> 'a t -> 'a t

(** [List.unordered_append l1 l2] has the same elements as [l1 @ l2], but in some
    unspecified order.  Generally takes time proportional to length of first list, but is
    O(1) if either list is empty. *)
val unordered_append : 'a t -> 'a t -> 'a t

(** [List.rev_map l ~f] gives the same result as
   {!List.rev}[ (]{!ListLabels.map}[ f l)], but is more efficient. *)
val rev_map : 'a t -> f:('a -> 'b) -> 'b t

(** [fold_left] is the same as [fold], and one should always use [fold] rather than
    [fold_left], except in functors that are parameterized over a more general signature
    where this equivalence does not hold.
*)
val fold_left : 'a t -> init:'b -> f:('b -> 'a -> 'b) -> 'b

(** [List.iter2_exn [a1; ...; an] [b1; ...; bn] ~f] calls in turn
    [f a1 b1; ...; f an bn].
    Raise if the two lists have different lengths. *)
val iter2_exn : 'a t -> 'b t -> f:('a -> 'b -> unit) -> unit

(** [List.rev_map2_exn l1 l2 ~f] gives the same result as
    [List.rev (List.map2_exn l1 l2 ~f)], but is more efficient. *)
val rev_map2_exn: 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t

(** [List.fold2_exn ~f ~init:a [b1; ...; bn] [c1; ...; cn]] is
   [f (... (f (f a b1 c1) b2 c2) ...) bn cn].
   Raise if the two lists have different lengths. *)
val fold2_exn
  :  'a t
  -> 'b t
  -> init:'c
  -> f:('c -> 'a -> 'b -> 'c)
  -> 'c

(** Like {!List.for_all}, but passes the index as an argument. *)
val for_alli : 'a t -> f:(int -> 'a -> bool) -> bool

(** Like {!List.for_all}, but for a two-argument predicate.
   Raise if the two lists have different lengths. *)
val for_all2_exn : 'a t -> 'b t -> f:('a -> 'b -> bool) -> bool

(** Like {!List.exists}, but passes the index as an argument. *)
val existsi : 'a t -> f:(int -> 'a -> bool) -> bool

(** Like {!List.exists}, but for a two-argument predicate.  Raise
    if the end of one list is reached before the end of the other. *)
val exists2_exn : 'a t -> 'b t -> f:('a -> 'b -> bool) -> bool

(** [filter l ~f] returns all the elements of the list [l] that satisfy the predicate [p].
    The order of the elements in the input list is preserved. *)
val filter : 'a t -> f:('a -> bool) -> 'a t

(** Like [filter], but reverses the order of the input list *)
val rev_filter : 'a t -> f:('a -> bool) -> 'a t

val filteri : 'a t -> f: (int -> 'a -> bool) -> 'a t

(** [partition_map t ~f] partitions [t] according to [f]. *)
val partition_map : 'a t -> f:('a -> [ `Fst of 'b | `Snd of 'c ]) -> 'b t * 'c t

(** [partition_tf l ~f] returns a pair of lists [(l1, l2)], where [l1] is the list of all the
    elements of [l] that satisfy the predicate [p], and [l2] is the list of all the
    elements of [l] that do not satisfy [p].  The order of the elements in the input list
    is preserved.  The "tf" suffix is mnemonic to remind readers at a call that the result
    is (trues, falses). *)
val partition_tf : 'a t -> f:('a -> bool) -> 'a t * 'a t

(** [split_n n \[e1; ...; em\]] is [(\[e1; ...; en\], \[en+1; ...; em\])].  If [n > m],
    [(\[e1; ...; em\], \[\])] is returned.  If [n < 0], [(\[\], \[e1; ...; em\])] is
    returned. *)
val split_n : 'a t -> int -> 'a t * 'a t

(** Sort a list in increasing order according to a comparison function.  The comparison
    function must return 0 if its arguments compare as equal, a positive integer if the
    first is greater, and a negative integer if the first is smaller (see Array.sort for a
    complete specification).  For example, {!Pervasives.compare} is a suitable comparison
    function.

    The current implementation uses Merge Sort. It runs in linear heap space and
    logarithmic stack space.

    Presently, the sort is stable, meaning that two equal elements in the input will be in
    the same order in the output. *)
val sort : cmp:('a -> 'a -> int) -> 'a t -> 'a t

(** Like [sort], but guaranteed to be stable *)
val stable_sort : cmp:('a -> 'a -> int) -> 'a t -> 'a t

(** Merge two lists: assuming that [l1] and [l2] are sorted according to the comparison
    function [cmp], [merge cmp l1 l2] will return a sorted list containing all the
    elements of [l1] and [l2].  If several elements compare equal, the elements of [l1]
    will be before the elements of [l2]. *)
val merge : 'a t -> 'a t -> cmp:('a -> 'a -> int) -> 'a t

val hd : 'a t -> 'a option

val tl : 'a t -> 'a t option

(** Return the first element of the given list. Raise if the list is empty. *)
val hd_exn : 'a t -> 'a

(** Return the given list without its first element. Raise if the list is empty. *)
val tl_exn : 'a t -> 'a t

val findi : 'a t -> f:(int -> 'a -> bool) -> (int * 'a) option

(** [find_exn t ~f] returns the first element of [t] that satisfies [f].  It raises
    [Not_found] if there is no such element. *)
val find_exn : 'a t -> f:('a -> bool) -> 'a

(** Returns the first evaluation of [f] that returns [Some].  Raises [Not_found] if [f]
    always returns [None].  *)
val find_map_exn : 'a t -> f:('a -> 'b option) -> 'b

(** Like [find_map] and [find_map_exn], but pass the index as an argument. *)
val find_mapi     : 'a t -> f:(int -> 'a -> 'b option) -> 'b option
val find_mapi_exn : 'a t -> f:(int -> 'a -> 'b option) -> 'b

(** E.g. [append [1; 2] [3; 4; 5]] is [[1; 2; 3; 4; 5]] *)
val append : 'a t -> 'a t -> 'a t

(** [List.map f [a1; ...; an]] applies function [f] to [a1, ..., an], and builds the list
    [[f a1; ...; f an]] with the results returned by [f]. *)
val map : 'a t -> f:('a -> 'b) -> 'b t

(** [concat_map t ~f] is [concat (map t ~f)], except that there is no guarantee about the
    order in which [f] is applied to the elements of [t]. *)
val concat_map : 'a t -> f:('a -> 'b t) -> 'b t

(** [concat_mapi t ~f] is like concat_map, but passes the index as an argument
*)
val concat_mapi : 'a t -> f:(int -> 'a -> 'b t) -> 'b t

(** [List.map2_exn [a1; ...; an] [b1; ...; bn] ~f] is [[f a1 b1; ...; f an bn]].  Raise
    if the two lists have different lengths. *)
val map2_exn :'a t -> 'b t ->  f:('a -> 'b -> 'c) -> 'c t

val rev_map3_exn : 'a t -> 'b t -> 'c t -> f:('a -> 'b -> 'c -> 'd) -> 'd t
val map3_exn : 'a t -> 'b t -> 'c t -> f:('a -> 'b -> 'c -> 'd) -> 'd t

(** [rev_map_append l1 l2 ~f] reverses [l1] mapping [f] over each
    element, and appends the result to the front of [l2]. *)
val rev_map_append : 'a t -> 'b t -> f:('a -> 'b) -> 'b t

(** [List.fold_right [a1; ...; an] ~f ~init:b] is
    [f a1 (f a2 (... (f an b) ...))]. *)
val fold_right : 'a t -> f:('a -> 'b -> 'b) -> init:'b -> 'b

(** Transform a list of pairs into a pair of lists:
    [unzip [(a1,b1); ...; (an,bn)]] is [([a1; ...; an], [b1; ...; bn])]. *)
val unzip : ('a * 'b) t -> 'a t * 'b t

(** Transform a pair of lists into an (optional) list of pairs:
    [zip [a1; ...; an] [b1; ...; bn]] is [[(a1,b1); ...; (an,bn)]].
    Returns None if the two lists have different lengths. *)
val zip     : 'a t -> 'b t -> ('a * 'b) t option
val zip_exn : 'a t -> 'b t -> ('a * 'b) t

(** mapi is just like map, but it also passes in the index of each
    element as the first argument to the mapped function. Tail-recursive. *)
val mapi : 'a t -> f:(int -> 'a -> 'b) -> 'b t

val rev_mapi : 'a t -> f:(int -> 'a -> 'b) -> 'b t

(** iteri is just like iter, but it also passes in the index of each
    element as the first argument to the iter'd function. Tail-recursive. *)
val iteri : 'a t ->  f:(int -> 'a -> unit) -> unit

(** foldi is just like fold, but it also passes in the index of each
    element as the first argument to the folded function.  Tail-recursive. *)
val foldi : 'a t -> f:(int -> 'b -> 'a -> 'b) -> init:'b -> 'b

(** [reduce_exn [a1; ...; an] ~f] is [f (... (f (f a1 a2) a3) ...) an].  It fails on the
    empty list.  Tail recursive. *)
val reduce_exn : 'a t -> f:('a -> 'a -> 'a) -> 'a
val reduce     : 'a t -> f:('a -> 'a -> 'a) -> 'a option

(** [reduce_balanced] returns the same value as [reduce] when [f] is associative, but
    differs in that the tree of nested applications of [f] has logarithmic depth.

    This is useful when your ['a] grows in size as you reduce it and [f] becomes more
    expensive with bigger inputs.  For example, [reduce_balanced ~f:(^)] takes [n*log(n)]
    time, while [reduce ~f:(^)] takes quadratic time. *)
val reduce_balanced     : 'a t -> f:('a -> 'a -> 'a) -> 'a option
val reduce_balanced_exn : 'a t -> f:('a -> 'a -> 'a) -> 'a

(** [group l ~break] returns a list of lists (i.e., groups) whose concatenation is
    equal to the original list.  Each group is broken where break returns true on
    a pair of successive elements.

    Example

    group ~break:(<>) ['M';'i';'s';'s';'i';'s';'s';'i';'p';'p';'i'] ->

    [['M'];['i'];['s';'s'];['i'];['s';'s'];['i'];['p';'p'];['i']]
*)
val group : 'a t -> break:('a -> 'a -> bool) -> 'a t t

(** This is just like group, except that you get the index in the original list of the
    current element along with the two elements.

    Example, group the chars of Mississippi into triples

    groupi ~break:(fun i _ _ -> i mod 3 = 0)
    ['M';'i';'s';'s';'i';'s';'s';'i';'p';'p';'i'] ->

    [['M'; 'i'; 's']; ['s'; 'i'; 's']; ['s'; 'i'; 'p']; ['p'; 'i']]
*)
val groupi : 'a t -> break:(int -> 'a -> 'a -> bool) -> 'a t t

(** The final element of a list.  The _exn version raises on the empty list. *)
val last : 'a t -> 'a option
val last_exn : 'a t -> 'a

(** [is_prefix xs ~prefix] returns [true] if [xs] starts with [prefix]. *)
val is_prefix : 'a t -> prefix:'a t -> equal:('a -> 'a -> bool) -> bool


(** [find_consecutive_duplicate t ~equal] returns the first pair of consecutive elements
    [(a1, a2)] in [t] such that [equal a1 a2].  They are returned in the same order as
    they appear in [t].  [equal] need not be an equivalence relation; it is simply used as
    a predicate on consecutive elements. *)
val find_consecutive_duplicate : 'a t -> equal:('a -> 'a -> bool) -> ('a * 'a) option

(** [remove_consecutive_duplicates]. The same list with consecutive duplicates removed.
    The relative order of the other elements is unaffected.
    The element kept from a run of duplicates is the last one. *)
val remove_consecutive_duplicates : 'a t -> equal:('a -> 'a -> bool) -> 'a t

(** [dedup] (de-duplicate).  The same list with duplicates removed, but the
    order is not guaranteed. *)
val dedup : ?compare:('a -> 'a -> int) -> 'a t -> 'a t

(** [contains_dup] True if there are any two elements in the list which are the same. *)
val contains_dup : ?compare:('a -> 'a -> int) -> 'a t -> bool

(** [find_a_dup] returns a duplicate from the list (no guarantees about which
    duplicate you get), or None if there are no dups. *)
val find_a_dup : ?compare:('a -> 'a -> int) -> 'a t -> 'a option

(** [find_all_dups] returns a list of all elements that occur more than once, with
    no guarantees about order. *)
val find_all_dups : ?compare:('a -> 'a -> int) -> 'a t -> 'a list

(** only raised in [exn_if_dup] below *)
exception Duplicate_found of (unit -> Sexplib.Sexp.t) * string

(** [exn_if_dup ?compare ?context t ~to_sexp] will run [find_a_dup] on [t], and raise
    [Duplicate_found] if a duplicate is found.  The [context] is the second argument of
    the exception *)
val exn_if_dup
  :  ?compare:('a -> 'a -> int)
  -> ?context:string
  -> 'a t
  -> to_sexp:('a -> Sexplib.Sexp.t)
  -> unit

(** [count l ~f] is the number of elements in [l] that satisfy the predicate [f]. *)
val count  : 'a t -> f:(       'a -> bool) -> int
val counti : 'a t -> f:(int -> 'a -> bool) -> int

(** [range ?stride ?start ?stop start_i stop_i] is the list of integers from [start_i] to
    [stop_i], stepping by [stride].  If [stride] < 0 then we need [start_i] > [stop_i] for
    the result to be nonempty (or [start_i] = [stop_i] in the case where both bounds are
    inclusive). *)
val range
  :  ?stride:int                            (** default = 1 *)
  -> ?start:[`inclusive|`exclusive]         (** default = `inclusive *)
  -> ?stop:[`inclusive|`exclusive]          (** default = `exclusive *)
  -> int
  -> int
  -> int t

(** [range'] is analogous to [range] for general start/stop/stride types.  [range'] raises
    if [stride x] returns [x] or if the direction that [stride x] moves [x] changes from
    one call to the next. *)
val range'
  :  compare:('a -> 'a -> int)
  -> stride:('a -> 'a)
  -> ?start:[`inclusive|`exclusive]         (** default = `inclusive *)
  -> ?stop:[`inclusive|`exclusive]          (** default = `exclusive *)
  -> 'a
  -> 'a
  -> 'a t

(** [init n ~f] is [[(f 0); (f 1); ...; (f (n-1))]].  It is an error if [n < 0].
    [List.init] applies [f] to values in decreasing order; starting with [n-1], and ending
    with [0]. This is the opposite order to [Array.init]. *)
val init : int -> f:(int -> 'a) -> 'a t

(** [rev_filter_map l ~f] is the reversed sublist of [l] containing
    only elements for which [f] returns [Some e]. *)
val rev_filter_map : 'a t -> f:('a -> 'b option) -> 'b t

(** rev_filter_mapi is just like rev_filter_map, but it also passes in the index of each
    element as the first argument to the mapped function. Tail-recursive. *)
val rev_filter_mapi : 'a t -> f:(int -> 'a -> 'b option) -> 'b t

(** [filter_map l ~f] is the sublist of [l] containing only elements
    for which [f] returns [Some e].  *)
val filter_map : 'a t -> f:('a -> 'b option) -> 'b t

(** filter_mapi is just like filter_map, but it also passes in the index of each
    element as the first argument to the mapped function. Tail-recursive. *)
val filter_mapi : 'a t -> f:(int -> 'a -> 'b option) -> 'b t

(** [filter_opt l] is the sublist of [l] containing only elements
    which are [Some e].  In other words, [filter_opt l] = [filter_map ~f:ident l]. *)
val filter_opt : 'a option t -> 'a t

(** Interpret a list of (key, value) pairs as a map in which only the first
    occurrence of a key affects the semantics, i.e.:

    {[List.Assoc.xxx alist ...args... ]}

    is always the same as (or at least sort of isomorphic to):

    {[ Map.xxx (alist |! Map.of_alist_multi |! Map.map ~f:List.hd) ...args... }]
*)
module Assoc : sig

  type ('a, 'b) t = ('a * 'b) list [@@deriving bin_io, sexp, compare]

  val add      : ('a, 'b) t -> ?equal:('a -> 'a -> bool) -> 'a -> 'b -> ('a, 'b) t
  val find     : ('a, 'b) t -> ?equal:('a -> 'a -> bool) -> 'a -> 'b option
  val find_exn : ('a, 'b) t -> ?equal:('a -> 'a -> bool) -> 'a -> 'b
  val mem      : ('a, 'b) t -> ?equal:('a -> 'a -> bool) -> 'a -> bool
  val remove   : ('a, 'b) t -> ?equal:('a -> 'a -> bool) -> 'a -> ('a, 'b) t
  val map      : ('a, 'b) t -> f:('b -> 'c) -> ('a, 'c) t
  (** Bijectivity is not guaranteed because we allow a key to appear more than once. *)
  val inverse  : ('a, 'b) t -> ('b, 'a) t
end

(** Note that [sub], unlike [slice], doesn't use python-style indices! *)
(** [sub pos len l] is the [len]-element sublist of [l], starting at [pos]. *)
val sub : 'a t -> pos:int -> len:int -> 'a t

(** [slice l start stop] returns a new list including elements [l.(start)] through
    [l.(stop-1)], normalized python-style. *)
val slice : 'a t -> int -> int -> 'a t

(** [take l n] is [fst (split_n n l)].
    [drop l n] is [snd (split_n n l)]. *)
val take : 'a t -> int -> 'a t
val drop : 'a t -> int -> 'a t

(** [take_while l ~f] returns the longest prefix of [l] for which [f] is [true]. *)
val take_while : 'a t -> f : ('a -> bool) -> 'a t

(** [drop_while l ~f] drops the longest prefix of [l] for which [f] is [true]. *)
val drop_while : 'a t -> f : ('a -> bool) -> 'a t

(** [split_while xs ~f = (take_while xs ~f, drop_while xs ~f)] *)
val split_while : 'a t -> f : ('a -> bool) -> 'a t * 'a t

(** Concatenate a list of lists.  The elements of the argument are all concatenated
    together (in the same order) to give the result.  Tail recursive over outer and inner
    lists. *)
val concat : 'a t t -> 'a t

(** Like [concat], but faster and without preserving any ordering (i.e. for lists that are
    essentially viewed as multi-sets. *)
val concat_no_order : 'a t t -> 'a t

val cons : 'a -> 'a t -> 'a t

(** Returns a list with all possible pairs -- if the input lists have length len1 and
    len2, the resulting list will have length len1*len2. *)
val cartesian_product : 'a t -> 'b t -> ('a * 'b) t

val to_string : f:('a -> string) -> 'a t -> string

(** [permute ?random_state t] returns a permutation of [t].

    [permute] side affects [random_state] by repeated calls to [Random.State.int].
    If [random_state] is not supplied, [permute] uses [Random.State.default]. *)
val permute : ?random_state:Core_random.State.t -> 'a t -> 'a t

(** [is_sorted t ~compare] returns [true] iff forall adjacent [a1; a2] in [t], [compare a1
    a2 <= 0].

    [is_sorted_strictly] is similar, except it uses [<] instead of [<=]. *)
val is_sorted          : 'a t -> compare:('a -> 'a -> int) -> bool
val is_sorted_strictly : 'a t -> compare:('a -> 'a -> int) -> bool

val equal : 'a t -> 'a t -> equal:('a -> 'a -> bool) -> bool

module Infix : sig
  val ( @ ) : 'a t -> 'a t -> 'a t
end

(** [transpose m] transposes the rows and columns of the matrix [m],
    considered as either a row of column lists or (dually) a column of row lists.

    Example,

    transpose [[1;2;3];[4;5;6]] = [[1;4];[2;5];[3;6]]

    On non-empty rectangular matrices, [transpose] is an involution
    (i.e., [transpose (transpose m) = m]).  Transpose returns None when called
    on lists of lists with non-uniform lengths.
**)
val transpose : 'a t t -> 'a t t option

(** [transpose_exn] transposes the rows and columns of its argument, throwing an exception
    if the list is not rectangular.
 **)
val transpose_exn : 'a t t -> 'a t t

(** [intersperse xs ~sep] places [sep] between adjacent elements of [xs].
    e.g. [intersperse [1;2;3] ~sep:0 = [1;0;2;0;3]] *)
val intersperse : 'a t -> sep:'a -> 'a t

(** Quickcheck generator for lists with additional customization.

    [List.gen' t] produces a generator for arbitrary lists of values from [t].

    Adding [~unique:true] guarantees that every value from [t] is included in each list
    at most once.

    - Adding [~length:(`Exactly n)] produces only lists of length [n].
    - Adding [~length:(`At_least n)] produces only lists of length [n] or greater.
    - Adding [~length:(`At_most n)] produces only lists of length [n] or less.
    - Adding [~length:(`Between_inclusive (m,n))] produces only lists of length [k] such
      that [m <= k] and [k <= n].

    Adding [~sorted:`Arbitrarily] produces lists that are sorted in a deterministic
    order based on the construction of [t], but not guaranteed to correspond to any
    specific comparison function.

    Adding [~sorted:(`By cmp)] produces lists that are sorted in ascending order by
    [cmp].

    The optional arguments can be combined; for example, the following expression
    creates lists of 10 to 20 integers each that are strictly sorted (no duplicates):

    {[
      gen' Int.gen
        ~unique:true
        ~sorted:(`By Int.compare)
        ~length:(`Between_inclusive (10,20))
    ]}

    Regardless of the options provided, the lists in the output of [list t] are
    generated uniquely, so long as the values in [t] are generated uniquely. *)
val gen'
  :  ?length : [ `Exactly           of int
               | `At_least          of int
               | `At_most           of int
               | `Between_inclusive of int * int ]
  -> ?unique : bool
  -> ?sorted : [ `Arbitrarily | `By of ('a -> 'a -> int) ]
  -> 'a Quickcheck.Generator.t
  -> 'a t Quickcheck.Generator.t

(** [gen_permutations t] generates all permutations of [list].  If [t]
    contains duplicate values, then [gen_permutations t] will produce
    duplicate lists. *)
val gen_permutations : 'a t -> 'a t Quickcheck.Generator.t
