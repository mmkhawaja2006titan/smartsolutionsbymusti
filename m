import React, { useState } from "react";

// Recursive Task Component
function Task({ task, toggleTask, addSubtask }) {
  const [showInput, setShowInput] = useState(false);
  const [subtaskText, setSubtaskText] = useState("");

  return (
    <div style={{ marginLeft: "20px", marginTop: "10px" }}>
      <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
        <input
          type="checkbox"
          checked={task.completed}
          onChange={() => toggleTask(task.id)}
        />

        <span
          style={{ textDecoration: task.completed ? "line-through" : "none" }}
        >
          {task.text}
        </span>

        {task.deadline && (
          <span style={{ color: "blue", fontSize: "12px" }}>
            {task.deadline}
          </span>
        )}

        <button onClick={() => setShowInput(!showInput)}>+ Subtask</button>
      </div>

      {showInput && (
        <div style={{ marginTop: "5px" }}>
          <input
            placeholder="Subtask name"
            value={subtaskText}
            onChange={(e) => setSubtaskText(e.target.value)}
          />
          <button
            onClick={() => {
              addSubtask(task.id, subtaskText);
              setSubtaskText("");
              setShowInput(false);
            }}
          >
            Add
          </button>
        </div>
      )}

      {task.subtasks.map((sub) => (
        <Task
          key={sub.id}
          task={sub}
          toggleTask={toggleTask}
          addSubtask={addSubtask}
        />
      ))}
    </div>
  );
}

// Calendar Component
function Calendar({ tasks }) {
  const dates = {};

  const collect = (list) => {
    list.forEach((t) => {
      if (t.deadline) {
        if (!dates[t.deadline]) dates[t.deadline] = [];
        dates[t.deadline].push(t.text);
      }
      collect(t.subtasks);
    });
  };

  collect(tasks);

  return (
    <div style={{ marginTop: "30px" }}>
      <h2>📅 Calendar</h2>
      {Object.keys(dates).map((date) => (
        <div
          key={date}
          style={{
            border: "1px solid #ccc",
            padding: "10px",
            marginBottom: "10px",
          }}
        >
          <strong>{date}</strong>
          <ul>
            {dates[date].map((t, i) => (
              <li key={i}>{t}</li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [text, setText] = useState("");
  const [deadline, setDeadline] = useState("");

  const createTask = (text, deadline) => ({
    id: Date.now() + Math.random(),
    text,
    deadline,
    completed: false,
    subtasks: [],
  });

  const addTask = () => {
    if (!text) return;
    setTasks([...tasks, createTask(text, deadline)]);
    setText("");
    setDeadline("");
  };

  const toggleTask = (id, list = tasks) => {
    return list.map((task) => {
      if (task.id === id) {
        return { ...task, completed: !task.completed };
      }
      return {
        ...task,
        subtasks: toggleTask(id, task.subtasks),
      };
    });
  };

  const updateTasks = (newTasks) => setTasks(newTasks);

  const addSubtask = (parentId, text) => {
    const addRecursive = (list) =>
      list.map((task) => {
        if (task.id === parentId) {
          return {
            ...task,
            subtasks: [...task.subtasks, createTask(text, "")],
          };
        }
        return {
          ...task,
          subtasks: addRecursive(task.subtasks),
        };
      });

    setTasks(addRecursive(tasks));
  };

  return (
    <div style={{ padding: "20px", maxWidth: "600px", margin: "auto" }}>
      <h1>✅ Checklist App</h1>

      {/* Add Task */}
      <div style={{ marginBottom: "20px" }}>
        <input
          placeholder="Task name"
          value={text}
          onChange={(e) => setText(e.target.value)}
          style={{ marginRight: "10px" }}
        />

        <input
          type="date"
          value={deadline}
          onChange={(e) => setDeadline(e.target.value)}
          style={{ marginRight: "10px" }}
        />

        <button onClick={addTask}>Add Task</button>
      </div>

      {/* Task List */}
      <div>
        {tasks.map((task) => (
          <Task
            key={task.id}
            task={task}
            toggleTask={(id) => updateTasks(toggleTask(id))}
            addSubtask={addSubtask}
          />
        ))}
      </div>

      {/* Calendar */}
      <Calendar tasks={tasks} />
    </div>
  );
}
