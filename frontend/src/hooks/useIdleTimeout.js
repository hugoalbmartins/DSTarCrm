import { useEffect, useRef } from 'react';

export function useIdleTimeout(onIdle, idleTime = 1800000) {
  const timeoutId = useRef(null);

  const resetTimer = () => {
    if (timeoutId.current) {
      clearTimeout(timeoutId.current);
    }

    timeoutId.current = setTimeout(() => {
      onIdle();
    }, idleTime);
  };

  useEffect(() => {
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click'];

    const handleActivity = () => {
      resetTimer();
    };

    events.forEach((event) => {
      window.addEventListener(event, handleActivity);
    });

    resetTimer();

    return () => {
      events.forEach((event) => {
        window.removeEventListener(event, handleActivity);
      });

      if (timeoutId.current) {
        clearTimeout(timeoutId.current);
      }
    };
  }, [idleTime, onIdle]);

  return null;
}
