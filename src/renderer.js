function create_button(
    text='Hello World!',
    top_pos='0px',
    right_pos='0px',
    font_size='13px',
    padding='1mm 1mm'
) {
    const btn = document.createElement('button');
    btn.className = 'button';
    btn.innerText = text;

    btn.style.position = 'absolute';
    btn.style.top = top_pos;
    btn.style.right = right_pos;
    btn.style.fontSize = font_size;
    btn.style.padding = padding;

    btn.style.pointerEvents = 'auto';

    btn.addEventListener('mouseenter', () => {
        ipcRenderer.send('set-ignore-mouse', false);
    });

    btn.addEventListener('mouseleave', () => {
        ipcRenderer.send('set-ignore-mouse', true);
    });

    btn.onclick = () => {
        console.log("Botão clicado com sucesso!");
        btn.style.backgroundColor = 'red';
    };

    container.appendChild(btn);
}

create_button();