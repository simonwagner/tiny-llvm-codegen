; ModuleID = 'test.ll'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

define i32 @test_return(i32 %arg) {
  ret i32 123
}

define i32 @test_add(i32 %arg) {
  %1 = add nsw i32 %arg, 100
  ret i32 %1
}

define i32 @test_sub(i32 %arg) {
  %1 = sub nsw i32 1000, %arg
  ret i32 %1
}

define i32 @test_load_int32(i32* nocapture %ptr) {
  %1 = load i32* %ptr
  ret i32 %1
}
define i16 @test_load_int16(i16* nocapture %ptr) {
  %1 = load i16* %ptr
  ret i16 %1
}
define i8 @test_load_int8(i8* nocapture %ptr) {
  %1 = load i8* %ptr
  ret i8 %1
}

define void @test_store_int32(i32* nocapture %ptr, i32 %value) {
  store i32 %value, i32* %ptr
  ret void
}
define void @test_store_int16(i16* nocapture %ptr, i16 %value) {
  store i16 %value, i16* %ptr
  ret void
}
define void @test_store_int8(i8* nocapture %ptr, i8 %value) {
  store i8 %value, i8* %ptr
  ret void
}

define i32* @test_load_ptr(i32** %ptr) {
  %1 = load i32** %ptr
  ret i32* %1
}

define i1 @test_compare(i32 %arg) {
  %1 = icmp eq i32 %arg, 99
  ret i1 %1
}

define i1 @test_compare_ptr(i32* %arg1, i32* %arg2) {
  %1 = icmp eq i32* %arg1, %arg2
  ret i1 %1
}

define i32 @test_branch(i32 %arg) {
  br label %label
label:
  ret i32 101
}

define i32 @test_conditional(i32 %arg) {
entry:
  %cmp = icmp eq i32 %arg, 99
  br i1 %cmp, label %iftrue, label %iffalse
iftrue:
  %ret1 = phi i32 [ 123, %entry ]
  ret i32 %ret1
iffalse:
  %ret2 = phi i32 [ 456, %entry ]
  ret i32 %ret2
}

define i32 @test_switch(i32 %arg) {
entry:
  switch i32 %arg, label %default [
    i32 1, label %match1
    i32 5, label %match5
  ]
match1:
  %ret1 = phi i32 [ 10, %entry ]
  ret i32 %ret1
match5:
  %ret5 = phi i32 [ 50, %entry ]
  ret i32 %ret5
default:
  %ret999 = phi i32 [ 999, %entry ]
  ret i32 %ret999
}

define i32 @test_phi(i32 %arg) {
  %1 = icmp eq i32 %arg, 99
  br i1 %1, label %iftrue, label %iffalse
iftrue:
  br label %return
iffalse:
  br label %return
return:
  %2 = phi i32 [ 123, %iftrue ], [ 456, %iffalse ]
  ret i32 %2
}

define i32 @test_select(i32 %arg) {
  %1 = icmp eq i32 %arg, 99
  %2 = select i1 %1, i32 123, i32 456
  ret i32 %2
}

define i32 @test_call(i32 (i32, i32)* %func, i32 %arg1, i32 %arg2) {
  %1 = call i32 %func(i32 %arg1, i32 %arg2)
  %2 = add i32 %1, 1000
  ret i32 %2
}

define i32 @test_call2(i32 (i32, i32)* %func, i32 %arg1, i32 %arg2) {
  %1 = call i32 %func(i32 %arg1, i32 %arg2)
  ; We are checking that the args don't clobber %1.
  %2 = call i32 %func(i32 0, i32 0)
  ret i32 %1
}

define i32 @test_direct_call() {
  %1 = call i32 @test_return(i32 0)
  ret i32 %1
}

@global1 = global i32 124

define i32* @get_global() {
  ret i32* @global1
}

@string = constant [7 x i8] c"Hello!\00"

define i8* @get_global_string() {
  ret i8* getelementptr ([7 x i8]* @string, i32 0, i32 0)
}

@array = constant [3 x [2 x i16]]
  [[2 x i16] [i16 1, i16 2],
   [2 x i16] [i16 3, i16 4],
   [2 x i16] [i16 5, i16 6]]

@ptr_reloc = global i32* @global1
@ptr_zero = global i32* null

%MyStruct = type { i8, i32, i8 }
@struct_val = global %MyStruct { i8 11, i32 22, i8 33 }
@struct_zero_init = global %MyStruct zeroinitializer

; Need to handle "undef": Clang generates it for the padding at the
; end of a struct.
@undef_init = global [8 x i8] undef

@global_getelementptr = global i8* getelementptr (%MyStruct* null, i32 0, i32 2)

@global_i64 = global i64 1234

; TODO: Disallow extern_weak global variables instead.
@__ehdr_start = extern_weak global i8

define i8* @get_weak_global() {
  ret i8* @__ehdr_start
}

define i32 @test_alloca() {
  %addr = alloca i32
  store i32 125, i32* %addr
  %1 = load i32* %addr
  ret i32 %1
}

define void @func_with_args(i32 %arg1, i32 %arg2) {
  ret void
}

define i32 @test_alloca2() {
  %addr = alloca i32
  store i32 125, i32* %addr
  ; We are checking that the args don't clobber %addr.
  call void @func_with_args(i32 98, i32 99)
  %1 = load i32* %addr
  ret i32 %1
}

define i32* @test_bitcast(i8* %arg) {
  %1 = bitcast i8* %arg to i32*
  ret i32* %1
}

define i8* @test_bitcast_global() {
  %ptr = bitcast i32** @ptr_reloc to i8*
  ret i8* %ptr
}

; TODO: Generate all these variants
; Zero-extension
define i32 @test_zext16(i32 %arg) {
  %1 = trunc i32 %arg to i16
  %2 = zext i16 %1 to i32
  ret i32 %2
}
define i32 @test_zext8(i32 %arg) {
  %1 = trunc i32 %arg to i8
  %2 = zext i8 %1 to i32
  ret i32 %2
}
define i32 @test_zext1(i32 %arg) {
  %1 = trunc i32 %arg to i1
  %2 = zext i1 %1 to i32
  ret i32 %2
}
; Sign-extension
define i32 @test_sext16(i32 %arg) {
  %1 = trunc i32 %arg to i16
  %2 = sext i16 %1 to i32
  ret i32 %2
}
define i32 @test_sext8(i32 %arg) {
  %1 = trunc i32 %arg to i8
  %2 = sext i8 %1 to i32
  ret i32 %2
}
define i32 @test_sext1(i32 %arg) {
  %1 = trunc i32 %arg to i1
  %2 = sext i1 %1 to i32
  ret i32 %2
}

define i32 @test_ptrtoint(i8* %arg) {
  %1 = ptrtoint i8* %arg to i32
  ret i32 %1
}
define i8* @test_inttoptr(i32 %arg) {
  %1 = inttoptr i32 %arg to i8*
  ret i8* %1
}

define i8* @test_getelementptr1() {
  %addr = getelementptr %MyStruct* @struct_val, i32 0, i32 2
  ret i8* %addr
}

define i16* @test_getelementptr2() {
  %addr = getelementptr [3 x [2 x i16]]* @array, i32 0, i32 2, i32 1
  ret i16* %addr
}

define i16* @test_getelementptr_constantexpr() {
  ret i16* getelementptr ([3 x [2 x i16]]* @array, i32 0, i32 2, i32 1)
}

define i8* @test_bitcast_constantexpr() {
  ret i8* bitcast ([3 x [2 x i16]]* @array to i8*)
}

define i32 @test_ptrtoint_constantexpr() {
  ret i32 ptrtoint ([3 x [2 x i16]]* @array to i32)
}

define i8* @test_inttoptr_constantexpr() {
  ret i8* inttoptr (i32 123456 to i8*)
}

declare void @llvm.memcpy.p0i8.p0i8.i32(i8*, i8*, i32, i32, i1)

define void @test_memcpy(i8* %dest, i8* %src, i32 %size) {
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %dest, i8* %src, i32 %size,
                                       i32 1, i1 0)
  ret void
}
