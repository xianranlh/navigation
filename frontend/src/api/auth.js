import request from './request'

export function login(data) {
    return request({
        url: '/auth/login',
        method: 'post',
        data
    })
}

export function getInfo() {
    return request({
        url: '/auth/me',
        method: 'get'
    })
}
