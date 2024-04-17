module todolist_addr::todolist {
  use aptos_framework::event;
  use std::signer;
  use aptos_std::table::{Self, Table};
  use aptos_framework::account;

  // Errors
const E_NOT_INITIALIZED: u64 = 1;
const ETASK_DOESNT_EXIST: u64 = 2;
const ETASK_IS_COMPLETED: u64 = 3;

  struct TodoList has key {
      tasks: Table<u64, Task>,
      set_task_event: event::EventHandle<Task>,
      task_counter: u64
    }

  struct Task has store, drop, copy {
      task_id: u64,
      address:address,
      content: String,
      completed: bool,
  }

  public entry fun create_task(account: &signer, content: String) acquires TodoList {
    // gets the signer address
    let signer_address = signer::address_of(account);
    // gets the TodoList resource
    let todo_list = borrow_global_mut<TodoList>(signer_address);
    // increment task counter
    let counter = todo_list.task_counter + 1;
    // creates a new Task
    let new_task = Task {
      task_id: counter,
      address: signer_address,
      content,
      completed: false
    };
    // adds the new task into the tasks table
    table::upsert(&mut todo_list.tasks, counter, new_task);
    // sets the task counter to be the incremented counter
    todo_list.task_counter = counter;
    // fires a new task created event
    event::emit_event<Task>(
      &mut borrow_global_mut<TodoList>(signer_address).set_task_event,
      new_task,
    );
  }

  public entry fun complete_task(account: &signer, task_id: u64) acquires TodoList {
  // gets the signer address
  let signer_address = signer::address_of(account);
  // gets the TodoList resource
  let todo_list = borrow_global_mut<TodoList>(signer_address);
  // gets the task matches the task_id
  let task_record = table::borrow_mut(&mut todo_list.tasks, task_id);
  // update task as completed
  task_record.completed = true;
}
public entry fun complete_task(account: &signer, task_id: u64) acquires TodoList {
  // gets the signer address
  let signer_address = signer::address_of(account);
  // assert signer has created a list
  assert!(exists<TodoList>(signer_address), 1);
  // gets the TodoList resource
  let todo_list = borrow_global_mut<TodoList>(signer_address);
  // assert task exists
  assert!(table::contains(&todo_list.tasks, task_id), 2);
  // gets the task matched the task_id
  let task_record = table::borrow_mut(&mut todo_list.tasks, task_id);
  // assert task is not completed
  assert!(task_record.completed == false, 3);
  // update task as completed
  task_record.completed = true;
}
}
