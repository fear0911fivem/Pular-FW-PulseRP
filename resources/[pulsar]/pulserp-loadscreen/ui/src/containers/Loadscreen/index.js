import React, { useState, useEffect, useCallback, useMemo, useRef } from 'react';
import { useSelector } from 'react-redux';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faDiscord, faSteam } from '@fortawesome/free-brands-svg-icons';
import bannerLogo from '../../logos/server-banner.png';
import mainLogo from '../../logos/server-logo.png';

// just copy this format to add imags
import bg from '../../backgrounds/bg-1.png';
import bg2 from '../../backgrounds/bg-2.png';
import bg3 from '../../backgrounds/bg-3.png';

const backgrounds = [bg, bg2, bg3]; // Add more images add bg# as you add them (:
const bgDuration = 5000; // 5 seconds per image
const fadeTime = 500; // 0.5 second fade

const loadingTips = [
  'Need help? Ask in our Discord!',
  'Report players by opening a ticket in Discord!',
  'Press F1 for utilities, emotes, and cash options!',
  'Press TAB to open your inventory!',
  'Press M to open your phone!',
  'Press L to lock/unlock your vehicle!',
  'Press F to enter/exit vehicles!',
  'Press Left Alt for third eye/interact menu!',
  'Press Z to cycle voice chat channels!',
  'Press N to speak in game voice chat!',
  'Buy phones and laptops at Digital Den!',
  'Make sure to read the server rules!',
  'Use /ooc for out-of-character chat!',
  'Use /me for roleplay actions!',
  'Use /scene to place text on walls and objects!',
  'Metagaming is prohibited - no using OOC info IC!',
  'Always initiate RP before hostile actions!',
  'Value your character\'s life - act realistically!',
  'No crimes 15 mins before/after server restart!',
  'Maximum 6 players for criminal activities!',
  'No external comms during active RP scenarios!',
  'Quality roleplay always comes first!',
  'Use common sense and respect other players!',
  'Admins have final say on all rule interpretations!'
];

const formatTime = () => {
  const now = new Date();
  return now.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: true
  }).toUpperCase();
};

const Logo = ({ name }) => (
  <div style={{
    position: 'absolute',
    width: 'fit-content',
    height: 'fit-content',
    textAlign: 'center',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    margin: 'auto',
    zIndex: 10,
    pointerEvents: 'none',
  }}>
    <h1 style={{
      color: '#ff0000',
      fontSize: '3rem',
      textShadow: '0 0 10px rgba(255, 0, 0, 0.5)',
      fontFamily: 'Oswald, sans-serif',
      margin: 0,
    }}>{name}</h1>
  </div>
);

const Loadscreen = () => {
  // Memoize loading tips to prevent recreation
  const memoizedLoadingTips = useMemo(() => loadingTips, []);

  const [currentTip, setCurrentTip] = useState(0);
  const [displayText, setDisplayText] = useState('');
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);
  const [currentTime, setCurrentTime] = useState(formatTime());
  const [testProgress, setTestProgress] = useState(0);
  const [testStageIndex, setTestStageIndex] = useState(0);
  const [isSpinning, setIsSpinning] = useState(false);
  
  // Slideshow state
  const [currentBg, setCurrentBg] = useState(0);
  const [bgOpacity, setBgOpacity] = useState(1);

  const testStages = [
    'INITIALIZING',
    'LOADING RESOURCES',
    'CONNECTING TO SERVER',
    'AUTHENTICATING',
    'FINISHING UP'
  ];

  const loadState = useSelector((state) => state?.load || {});

  const isDevelopment = process.env.NODE_ENV === 'development';

  const testData = {
    current: isDevelopment ? testProgress : (loadState.test?.current || 0),
    total: 100,
    currentStage: isDevelopment ? testStages[testStageIndex] : (loadState.currentStage || 'LOADING')
  };

  const pct = Math.min((testData.current / testData.total) * 100, 100);

  useEffect(() => {
    if (!isDevelopment) return;

    const timer = setInterval(() => {
      setTestProgress(prev => {
        const next = prev + Math.random() * 10;
        if (next >= 100) {
          clearInterval(timer);
          return 100;
        }
        return next;
      });

      setTestStageIndex(prev => {
        const newStage = Math.min(
          Math.floor((testProgress / 100) * testStages.length),
          testStages.length - 1
        );
        return newStage > prev ? newStage : prev;
      });

    }, 300);

    return () => clearInterval(timer);
  }, [isDevelopment, testProgress]);

  useEffect(() => {
    setDisplayText('');
    setCurrentIndex(0);
    setIsDeleting(false);
  }, [currentTip]);


  useEffect(() => {
    const currentTipText = loadingTips[currentTip];

    if (!isDeleting && currentIndex < currentTipText.length) {
      const timeout = setTimeout(() => {
        setDisplayText(prev => prev + currentTipText[currentIndex]);
        setCurrentIndex(prev => prev + 1);
      }, 80);
      return () => clearTimeout(timeout);
    }

    else if (isDeleting && currentIndex > 0) {
      const timeout = setTimeout(() => {
        setDisplayText(prev => prev.slice(0, -1));
        setCurrentIndex(prev => prev - 1);
      }, 60);
      return () => clearTimeout(timeout);
    }

    else if (!isDeleting && currentIndex === currentTipText.length) {
      const timeout = setTimeout(() => {
        setIsDeleting(true);
      }, 5000);
      return () => clearTimeout(timeout);
    }

    else if (isDeleting && currentIndex === 0) {
      setIsDeleting(false);
      // Trigger next random tip
      setCurrentTip(getRandomTip(currentTip));
    }
  }, [currentIndex, currentTip, isDeleting]);

  useEffect(() => {
    const timeInterval = setInterval(() => {
      setCurrentTime(formatTime());
    }, 60000);

    return () => {
      clearInterval(timeInterval);
    };
  }, []);

  useEffect(() => {
    if (backgrounds.length <= 1) return;

    const interval = setInterval(() => {
      setBgOpacity(0);
      
      setTimeout(() => {
        setCurrentBg((prev) => (prev + 1) % backgrounds.length);
        setBgOpacity(1);
      }, fadeTime);
    }, bgDuration);

    return () => clearInterval(interval);
  }, []);

  const loadingStages = [
    { id: 'init', label: 'INIT', threshold: 0 },
    { id: '3d', label: '3D MODEL PRELOAD', threshold: 25 },
    { id: 'world', label: 'WORLD LOAD', threshold: 50 },
    { id: 'ui', label: 'UI LOAD', threshold: 75 },
    { id: 'final', label: 'FINALIZING', threshold: 90 },
  ];

  const currentStageText = useMemo(() => {
    return loadingStages.reduce((current, stage) =>
      pct >= stage.threshold ? stage : current, loadingStages[0]
    ).label;
  }, [pct]);

  const progressPercentage = useMemo(() => Math.min((testData.current / testData.total) * 100, 100), [testData.current, testData.total]);

  const loadingTipsRef = useRef(memoizedLoadingTips);

  const handleDiscordClick = useCallback(() => {
    try {
      if (window.invokeNative) {
        window.invokeNative('openUrl', 'https://discord.gg/zbzUjAZ54y');
      } else {
        window.open('https://discord.gg/zbzUjAZ54y', '_blank');
      }
    } catch (e) {
      window.open('https://discord.gg/zbzUjAZ54y', '_blank');
    }
  }, []);

  const getRandomTip = useCallback((currentTipIndex) => {
    const tips = loadingTipsRef.current;
    let newTip;
    do {
      newTip = Math.floor(Math.random() * tips.length);
    } while (newTip === currentTipIndex && tips.length > 1);
    return newTip;
  }, []);

  return (
    <div style={styles.container}>
      <div style={{
        ...styles.backgroundImage,
        backgroundImage: `url(${backgrounds[currentBg]})`,
        opacity: bgOpacity,
        transition: `opacity ${fadeTime}ms ease-in-out`
      }} />

      <button
        onClick={handleDiscordClick}
        style={styles.discordButton}
        aria-label="Join our Discord"
      >
        <FontAwesomeIcon icon={faDiscord} style={styles.discordIcon} />
      </button>

      <div style={styles.tipContainer}>
        <div style={styles.tipLabel}>TIP</div>
        <div style={styles.tipText}>
          {displayText}
          <span style={{
            ...styles.cursor,
            color: '#00a8ff',
            fontWeight: 'bold',
            animation: currentIndex >= loadingTips[currentTip].length ? 'blink 1s step-end infinite' : 'none',
            opacity: currentIndex >= loadingTips[currentTip].length ? 1 : 0.8
          }}>|</span>
        </div>
      </div>

      <div style={styles.mainContent}>
        <div style={styles.loadingSection}>
          <div style={styles.progressWrapper}>
            <div style={styles.progressHeader}>
              <span>
                <span style={styles.loadingSlash}>//</span>
                <span style={styles.loadingText}> LOADING</span>
                <span className="loading-ellipsis" style={styles.ellipsis}></span>
              </span>
              <span style={styles.currentStageText}>{currentStageText}</span>
            </div>
            <div style={styles.progressContainer}>
              <div style={styles.progressBar}>
                <div
                  style={{
                    ...styles.progressFill,
                    width: `${progressPercentage}%`,
                    position: 'relative',
                    overflow: 'hidden',
                  }}
                >
                  <div style={styles.progressFlash} />
                </div>
              </div>
              <div style={styles.percentage}>{Math.round(progressPercentage)}%</div>
            </div>

            <div style={styles.bannerContainer}>
              <img
                src={bannerLogo}
                alt="Icedog Dev"
                style={styles.bannerLogo}
              />
            </div>
          </div>
        </div>

        <div style={styles.logoContainer}>
          <img
            src={mainLogo}
            alt="Logo"
            style={{
              ...styles.mainLogo,
              animation: 'spinStop 3s cubic-bezier(0.4, 0, 0.2, 1) infinite',
              transformOrigin: 'center center'
            }}
          />
        </div>
      </div>

      <style jsx global>{`
        @import url('https://fonts.googleapis.com/css2?family=Oswald:wght@400;500;600;700&family=Montserrat:wght@400;500;600;700&display=swap');
        
        @keyframes blink {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.3; }
        }
        
        .ellipsis:after {
          content: '.';
          animation: ellipsis 1.5s infinite;
          display: inline-block;
          width: 1em;
          text-align: left;
        }
        
        @keyframes ellipsis {
          0% { content: '.'; }
          33% { content: '..'; }
          66% { content: '...'; }
        }
        
        @keyframes spinStop {
          0%, 20% { 
            transform: rotate(0deg); 
          }
          70% { 
            transform: rotate(360deg); 
          }
          100% {
            transform: rotate(360deg);
          }
        }
        
        @keyframes flash {
          0% { transform: translateX(-100%); }
          20% { transform: translateX(-50%); }
          100% { transform: translateX(200%); }
        }
        
        @keyframes ellipsis {
          0% { content: ''; }
          33% { content: '.'; }
          66% { content: '..'; }
          100% { content: '...'; }
        }
        
        .loading-ellipsis {
            margin-left: 0px;
            display: inline-block;
            vertical-align: text-top;
            position: relative;
            top: -6px;
            font-family: 'Oswald', sans-serif;
            font-weight: 700;
            font-size: 1.4em;
            line-height: 1;
            letter-spacing: 0.2em;
        }
        .loading-ellipsis:after {
          content: '...';
          display: inline-block;
          width: 1.8em;
          text-align: left;
          animation: ellipsis 1.5s steps(4, end) infinite;
        }
      `}</style>
    </div>
  );
};

const styles = {
  cursor: {
    display: 'inline-block',
    marginLeft: '2px',
    animation: 'blink 1s infinite'
  },
  container: {
    position: 'fixed',
    top: 0,
    left: 0,
    width: '100vw',
    height: '100vh',
    backgroundColor: '#0a0a0f',
    color: '#bb1515',
    fontFamily: '"Montserrat", sans-serif',
    display: 'flex',
    flexDirection: 'column',
    overflow: 'hidden',
    cursor: 'default',
    '*': {
      cursor: 'inherit',
    },
    'button, a': {
      cursor: 'pointer',
    },
  },
  backgroundImage: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    backgroundImage: `url(${bg})`,
    backgroundSize: 'cover',
    backgroundPosition: 'center',
    opacity: 1,
    zIndex: 1,
  },
  mainContent: {
    flex: 1,
    display: 'flex',
    position: 'relative',
    zIndex: 2,
    padding: '40px',
  },
  loadingSection: {
    position: 'absolute',
    bottom: '20px',
    left: '40px',
    display: 'flex',
    flexDirection: 'column',
    maxWidth: '425px',
    width: '60%',
  },
  loadingInfo: {
    maxWidth: '600px',
  },
  loadingText: {
    fontSize: '18px',
    fontWeight: 500,
    color: '#b91616',
    marginBottom: '15px',
    textTransform: 'uppercase',
    letterSpacing: '1px',
  },
  progressWrapper: {
    marginTop: '20px',
    maxWidth: '600px',
    width: '100%',
  },
  progressHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '8px',
  },
  loadingText: {
    color: '#bb1515',
    fontSize: '28px',
    fontFamily: '"Oswald", sans-serif',
    fontWeight: 'bold',
  },
  loadingSlash: {
    color: '#bb1515',
    fontSize: '29px',
    fontFamily: '"Oswald", sans-serif',
    fontWeight: 'bold',
  },
  currentStageText: {
    color: '#9CA3AF',
    fontSize: '20px',
    fontFamily: '"Oswald", sans-serif',
    textTransform: 'uppercase',
    letterSpacing: '1px',
    fontWeight: 'bold',
  },
  progressContainer: {
    display: 'flex',
    alignItems: 'center',
    gap: '15px',
    margin: '10px 0 15px 0',
  },
  progressBar: {
    flex: 1,
    height: '16px',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    borderRadius: '3px',
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    background: 'linear-gradient(90deg, #bb1515 0%, #0059fe 100%)',
    borderRadius: '2px',
    position: 'relative',
    transition: 'width 0.3s ease-out',
    boxShadow: '0 0 10px rgba(255, 0, 0, 0.5)',
    overflow: 'hidden',
  },
  progressFlash: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, rgba(255, 0, 0, 0.8) 50%, rgba(255, 255, 255, 0) 100%)',
    animation: 'flash 2s ease-in-out infinite',
    transform: 'translateX(-100%)',
    filter: 'blur(5px)'
  },
  percentage: {
    display: 'none',
    color: '#bb1515',
    fontWeight: '700'
  },
  tipContainer: {
    position: 'absolute',
    top: '30px',
    left: '30px',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-start',
    maxWidth: '400px',
    zIndex: 10,
    fontFamily: '"Oswald", sans-serif'
  },
  tipLabel: {
    fontSize: '14px',
    fontWeight: 700,
    color: '#ff0000',
    textTransform: 'uppercase',
    letterSpacing: '1px',
    fontFamily: '"Oswald", sans-serif',
    marginBottom: '4px'
  },
  tipText: {
    fontSize: '16px',
    color: '#bb1515',
    fontFamily: '"Oswald", sans-serif',
    fontWeight: 400,
    lineHeight: 1.4
  },
  bannerContainer: {
    marginTop: '20px',
    maxWidth: '300px',
  },
  bannerLogo: {
    width: '100%',
    height: 'auto',
    display: 'block',
  },
  logoContainer: {
    position: 'absolute',
    bottom: '20px',
    right: '20px',
    display: 'flex',
    alignItems: 'flex-end',
    zIndex: 5,
  },
  mainLogo: {
    width: '120px',
    height: 'auto',
    filter: 'drop-shadow(0 0 20px rgba(0, 0, 0, 0.5))',
  },
  discordButton: {
    position: 'absolute',
    top: '30px',
    right: '30px',
    width: '36px',
    height: '36px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    color: 'white',
    border: '1px solid rgba(255, 255, 255, 0.2)',
    borderRadius: '4px',
    padding: 0,
    cursor: 'pointer',
    zIndex: 10,
    transition: 'all 0.2s ease',
    '&:hover': {
      backgroundColor: 'rgba(88, 101, 242, 0.2)',
      borderColor: 'rgba(255, 0, 0, 0.5)',
    },
  },
  discordIcon: {
    fontSize: '16px',
    color: 'rgba(201, 20, 20, 0.9)',
    transition: 'transform 0.2s ease',
    'button:hover &': {
      transform: 'scale(1.1)'
    }
  },
  devNote: {
    marginTop: '10px',
    fontSize: '11px',
    color: 'rgba(255, 255, 255, 0.5)',
    fontStyle: 'italic',
    lineHeight: '1.4',
  },

  stagesContainer: {
    marginBottom: '30px',
    fontFamily: 'monospace',
  },
  stagesTitle: {
    color: '#bb1515',
    fontSize: '14px',
    marginBottom: '10px',
    letterSpacing: '1px',
  },
  stageItem: {
    fontSize: '13px',
    margin: '5px 0',
    letterSpacing: '0.5px',
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
  },
  socialLink: {
    color: 'rgba(255, 255, 255, 0.6)',
    fontSize: '18px',
    transition: 'color 0.2s',
    '&:hover': {
      color: '#bb1515',
    }
  }
};

export default Loadscreen;
