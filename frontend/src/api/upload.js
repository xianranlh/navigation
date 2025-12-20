import request from './request'

// 上传单张图片
export function uploadImage(file) {
    const formData = new FormData()
    formData.append('image', file)

    return request.post('/upload/image', formData, {
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}

// 上传多张图片
export function uploadImages(files) {
    const formData = new FormData()
    files.forEach(file => {
        formData.append('images', file)
    })

    return request.post('/upload/images', formData, {
        headers: {
            'Content-Type': 'multipart/form-data'
        }
    })
}
