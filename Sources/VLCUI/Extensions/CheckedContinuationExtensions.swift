extension CheckedContinuation where E == Never {

    func resume<Value, Failure: Error>(failure: Failure) where T == Result<Value, Failure> {
        resume(returning: .failure(failure))
    }

    func resume<Value, Failure: Error>(success: Value) where T == Result<Value, Failure> {
        resume(returning: .success(success))
    }
}
