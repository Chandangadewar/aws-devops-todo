require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || '1.0.0';
const ENV = process.env.NODE_ENV || 'development';

// ── Middleware ────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path} → ${res.statusCode} (${Date.now() - start}ms)`);
  });
  next();
});

// ── In-memory Todo Store ──────────────────────────────
let todos = [
  { id: 1, title: 'Set up AWS EC2 instance', completed: true,  priority: 'high',   createdAt: new Date().toISOString() },
  { id: 2, title: 'Install Docker on EC2',   completed: true,  priority: 'high',   createdAt: new Date().toISOString() },
  { id: 3, title: 'Configure GitHub Actions', completed: false, priority: 'high',   createdAt: new Date().toISOString() },
  { id: 4, title: 'Set up Nginx reverse proxy', completed: false, priority: 'medium', createdAt: new Date().toISOString() },
  { id: 5, title: 'Push Docker image to Docker Hub', completed: false, priority: 'medium', createdAt: new Date().toISOString() },
];
let nextId = 6;

// ── Health Check ──────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({
    status:      'healthy',
    version:     VERSION,
    environment: ENV,
    uptime:      Math.floor(process.uptime()) + 's',
    timestamp:   new Date().toISOString(),
    hostname:    require('os').hostname(),
    memory: {
      used:  Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB',
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + 'MB'
    }
  });
});

// ── Todo CRUD API ─────────────────────────────────────

// GET all todos
app.get('/api/todos', (req, res) => {
  const { priority, completed } = req.query;
  let result = [...todos];
  if (priority)  result = result.filter(t => t.priority === priority);
  if (completed !== undefined) result = result.filter(t => t.completed === (completed === 'true'));
  res.json({ count: result.length, todos: result });
});

// GET single todo
app.get('/api/todos/:id', (req, res) => {
  const todo = todos.find(t => t.id === parseInt(req.params.id));
  if (!todo) return res.status(404).json({ error: 'Todo not found' });
  res.json(todo);
});

// POST create todo
app.post('/api/todos', (req, res) => {
  const { title, priority = 'medium' } = req.body;
  if (!title?.trim()) return res.status(400).json({ error: 'Title is required' });
  if (!['low', 'medium', 'high'].includes(priority)) {
    return res.status(400).json({ error: 'Priority must be low, medium, or high' });
  }
  const todo = { id: nextId++, title: title.trim(), completed: false, priority, createdAt: new Date().toISOString() };
  todos.push(todo);
  res.status(201).json(todo);
});

// PATCH update todo
app.patch('/api/todos/:id', (req, res) => {
  const idx = todos.findIndex(t => t.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'Todo not found' });
  const { title, completed, priority } = req.body;
  if (title !== undefined)     todos[idx].title = title.trim();
  if (completed !== undefined) todos[idx].completed = Boolean(completed);
  if (priority !== undefined)  todos[idx].priority = priority;
  todos[idx].updatedAt = new Date().toISOString();
  res.json(todos[idx]);
});

// DELETE todo
app.delete('/api/todos/:id', (req, res) => {
  const idx = todos.findIndex(t => t.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'Todo not found' });
  todos.splice(idx, 1);
  res.json({ message: 'Deleted successfully' });
});

// ── Serve Frontend ────────────────────────────────────
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ── Start Server ──────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`  🚀  Server started on port ${PORT}`);
  console.log(`  🌍  Environment : ${ENV}`);
  console.log(`  📦  Version     : ${VERSION}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
});
