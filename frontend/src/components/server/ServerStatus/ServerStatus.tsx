import styles from './ServerStatus.module.css'

export interface ServerStatusData {
  online: boolean
  playerCount: number
  paused?: boolean
}

interface ServerStatusProps {
  loading: boolean
  status?: ServerStatusData | null
  showPlayers?: boolean
}

const ServerStatus = ({ loading, status, showPlayers = true }: ServerStatusProps) => {
  if (loading) {
    return (
      <p>
        Status:{' '}
        <span className={styles.statusGroup}>
          <span className={`${styles.statusText} ${styles.loading}`}>Loading...</span>
        </span>
      </p>
    )
  }

  const isPaused = status?.paused ?? false
  const isOnline = status?.online ?? false
  const playerCount = status?.playerCount ?? 0

  let statusText = 'Offline'
  let statusClass = styles.offline
  let lampIcon = '/images/status/lamp-off.png'
  let lampAlt = 'Offline'

  if (isPaused) {
    statusText = 'Paused'
    lampAlt = 'Paused'
  } else if (isOnline) {
    statusText = 'Online'
    statusClass = styles.online
    lampIcon = '/images/status/lamp-on.png'
    lampAlt = 'Online'
  }

  return (
    <p>
      Status:{' '}
      <span className={styles.statusGroup}>
        <span className={`${styles.statusText} ${statusClass}`}>{statusText}</span>
        <img
          className={styles.lampIcon}
          src={lampIcon}
          alt={lampAlt}
        />
      </span>

      {isOnline && !isPaused && showPlayers && (
        <>
          <br />
          Players online:{' '}
          <span className={styles.statusGroup}>
            <span className={`${styles.statusText} ${playerCount > 0 ? styles.online : styles.offline}`}>
              {playerCount}
            </span>
            <img
              className={styles.lampIcon}
              src={playerCount > 0 ? '/images/status/lamp-on.png' : '/images/status/lamp-off.png'}
              alt={playerCount > 0 ? 'Players online' : 'No players online'}
            />
          </span>
        </>
      )}
    </p>
  )
}

export default ServerStatus
