tern.css("sidebar", [[
#sidebar .tn-vt-host-name,
#sidebar .nav-head,
#sidebar .nav-row {
    border: none;
    border-radius: 6px;
    outline: none;
}

#sidebar .tn-vt-host {
    margin-left: 0;
    margin-right: 0;
    padding-left: 0;
    padding-right: 0;
}

#sidebar .tn-vt-host-name {
    background-color: var(--l2);
    color: var(--t1);
    font-size: 1em;
    font-weight: 700;
    padding: 6px 12px;
    min-height: 32px;
}

#sidebar .nav-group {
    margin-left: 0;
}

#sidebar .nav-head {
    color: var(--t2);
    font-size: 0.85em;
    font-weight: 600;
    letter-spacing: 0.03em;
    border-radius: 0;
    margin-top: 0;
}

#sidebar .nav-head::before {
    content: "\25A3";
    font-size: 1.1em;
    line-height: 1;
}

#sidebar .nav-head > .n {
    display: none;
}

#sidebar .nav-items {
    margin-left: 16px;
}

#sidebar .nav-row .lbl {
    font-weight: 400;
}
]])
