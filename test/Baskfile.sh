## Sample Baskfile

task_one() {
    bask_parallel end
}

task_two() {
    bask_parallel one end
}

task_three() {
    bask_parallel one two end
}

task_end() {
    # do nothing
    echo -n
}

task_default() {
    bask_parallel one two three end
}
