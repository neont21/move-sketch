/**
 * @file MoveSketch Public Notices Service & Renderer
 */

/**
 * @typedef {Object} NoticeItem
 * @property {string} id
 * @property {string} title
 * @property {string} content
 * @property {string} createdAt
 * @property {boolean} isImportant
 * @property {string|null} actionUrl
 * @property {string|null} actionButtonText
 */

const FIRESTORE_NOTICES_ENDPOINT =
  'https://firestore.googleapis.com/v1/projects/move-sketch/databases/(default)/documents/notices?pageSize=50';

/**
 * HTML 특수문자를 이스케이프하여 XSS를 방지합니다.
 * @param {string} unsafeString
 * @returns {string}
 */
function escapeHtml(unsafeString) {
  if (!unsafeString) return '';
  return unsafeString
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

/**
 * Firestore REST 응답의 단일 필드 값을 파싱합니다.
 * @param {Object} fieldObject
 * @returns {any}
 */
function parseFirestoreField(fieldObject) {
  if (!fieldObject) return null;
  if ('stringValue' in fieldObject) return fieldObject.stringValue;
  if ('booleanValue' in fieldObject) return fieldObject.booleanValue;
  if ('integerValue' in fieldObject) return parseInt(fieldObject.integerValue, 10);
  if ('timestampValue' in fieldObject) return fieldObject.timestampValue;
  return null;
}

/**
 * ISO 일시 문자열을 YYYY.MM.DD 포맷으로 변환합니다.
 * @param {string} isoString
 * @returns {string}
 */
function formatDate(isoString) {
  if (!isoString) return '';
  try {
    const date = new Date(isoString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}.${month}.${day}`;
  } catch (_) {
    return '';
  }
}

/**
 * Firestore REST API로부터 공지사항 목록을 fetch합니다.
 * @returns {Promise<NoticeItem[]>}
 */
async function fetchNotices() {
  const response = await fetch(FIRESTORE_NOTICES_ENDPOINT);
  if (!response.ok) {
    throw new Error(`HTTP Error: ${response.status}`);
  }

  const data = await response.json();
  if (!data.documents || !Array.isArray(data.documents)) {
    return [];
  }

  /** @type {NoticeItem[]} */
  const notices = data.documents.map((document) => {
    const fields = document.fields || {};
    const pathParts = document.name.split('/');
    const id = pathParts[pathParts.length - 1];

    return {
      id,
      title: parseFirestoreField(fields.title) || '공지사항',
      content: parseFirestoreField(fields.content) || '',
      createdAt:
        parseFirestoreField(fields.createdAt) ||
        document.createTime ||
        new Date().toISOString(),
      isImportant: Boolean(parseFirestoreField(fields.isImportant)),
      actionUrl: parseFirestoreField(fields.actionUrl),
      actionButtonText: parseFirestoreField(fields.actionButtonText),
    };
  });

  notices.sort((itemA, itemB) => {
    if (itemA.isImportant !== itemB.isImportant) {
      return itemA.isImportant ? -1 : 1;
    }
    return new Date(itemB.createdAt).getTime() - new Date(itemA.createdAt).getTime();
  });

  return notices;
}

/**
 * 공지사항 단일 카드 요소를 생성합니다.
 * @param {NoticeItem} notice
 * @returns {HTMLElement}
 */
function createNoticeElement(notice) {
  const cardElement = document.createElement('article');
  cardElement.className = 'notice-card';

  const importantBadgeHtml = notice.isImportant
    ? '<span class="badge-important">중요</span>'
    : '';

  const formattedDate = formatDate(notice.createdAt);

  let actionButtonHtml = '';
  if (notice.actionUrl) {
    const buttonLabel = escapeHtml(notice.actionButtonText || '자세히 보기');
    const safeUrl = escapeHtml(notice.actionUrl);
    actionButtonHtml = `<div class="notice-action-wrapper"><a href="${safeUrl}" target="_blank" rel="noopener noreferrer" class="notice-action-button">${buttonLabel} &rarr;</a></div>`;
  }

  const cleanedContent = (notice.content || '')
    .trim()
    .replace(/\n{3,}/g, '\n\n');
  cardElement.innerHTML = `
    <button type="button" class="notice-header" aria-expanded="false">
      <div class="notice-title-group">
        ${importantBadgeHtml}
        <span class="notice-title">${escapeHtml(notice.title)}</span>
      </div>
      <div class="notice-meta-right">
        <span class="notice-date">${formattedDate}</span>
        <svg class="notice-chevron" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="6 9 12 15 18 9"></polyline>
        </svg>
      </div>
    </button>
    <div class="notice-body">
      <div class="notice-text">${escapeHtml(cleanedContent)}</div>
      ${actionButtonHtml}
    </div>
  `;

  const headerButton = cardElement.querySelector('.notice-header');
  headerButton.addEventListener('click', () => {
    const isCurrentlyOpen = cardElement.classList.contains('is-open');
    cardElement.classList.toggle('is-open', !isCurrentlyOpen);
    headerButton.setAttribute('aria-expanded', String(!isCurrentlyOpen));
  });

  return cardElement;
}

document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('notices-container');

  try {
    const notices = await fetchNotices();

    if (notices.length === 0) {
      container.innerHTML = '<div class="state-box">등록된 공지사항이 없습니다.</div>';
      return;
    }

    container.innerHTML = '';
    const listElement = document.createElement('div');
    listElement.className = 'notice-list';

    for (const notice of notices) {
      listElement.appendChild(createNoticeElement(notice));
    }

    container.appendChild(listElement);
  } catch (error) {
    console.error('공지사항 로딩 실패:', error);
    container.innerHTML =
      '<div class="state-box">공지사항을 불러오는 중 오류가 발생했습니다.<br>잠시 후 다시 시도해 주세요.</div>';
  }
});