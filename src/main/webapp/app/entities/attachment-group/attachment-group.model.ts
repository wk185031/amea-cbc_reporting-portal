import { BaseEntity } from './../../shared';
import { Attachment } from '../attachment';

export class AttachmentGroup implements BaseEntity {
    constructor(
        public id?: number,
        public entity?: string,
        public attachments?: Attachment[],
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
    ) {
    }
}
