import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AppLayout } from "@/components/notif/AppLayout";
import Inbox from "./pages/Inbox";
import SLA from "./pages/SLA";
import Rules from "./pages/Rules";
import Templates from "./pages/Templates";
import Preferences from "./pages/Preferences";
import Audit from "./pages/Audit";
import NotFound from "./pages/NotFound.tsx";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider delayDuration={150}>
      <Toaster />
      <Sonner position="top-right" closeButton richColors />
      <BrowserRouter>
        <Routes>
          <Route element={<AppLayout />}>
            <Route path="/" element={<Inbox />} />
            <Route path="/sla" element={<SLA />} />
            <Route path="/rules" element={<Rules />} />
            <Route path="/templates" element={<Templates />} />
            <Route path="/preferences" element={<Preferences />} />
            <Route path="/audit" element={<Audit />} />
          </Route>
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
