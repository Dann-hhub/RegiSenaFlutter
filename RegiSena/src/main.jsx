// src/main.jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';  // Esta importación necesita un export default
import './index.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);