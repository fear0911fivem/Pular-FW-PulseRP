import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { setupDevBrowser } from "./devBrowser";
import "./index.css";

setupDevBrowser();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
